# Source: https://github.com/nushell/nu_scripts/blob/e82487722bce88c11f6b31788142b29e4c40bda4/games/paperclips/game.nu

# nu-niversal paperclips - a (somewhat) faithful clone of Universal Paperclips
# play the original at: https://www.decisionproblem.com/paperclips/index2.html

# NOTE: scalars are off cuz i'm counting by pennies instead of dollars and cents

const carriage_return = "\n\r"

# Resets cursor to home position and hides it to prevent visual distraction
def reset-cursor [] {
  print -n "\e[H"  # Move cursor to home position (top-left)
  print -n "\e[?25l"  # Hide cursor
}

# Clears all content from cursor position to end of screen
def clear-to-end [] {
  print -n "\e[J"  # Clear from cursor to end of screen
}

# Updates the terminal display with current game state
def refresh-game-view [state] {
  reset-cursor
  render-game-display $state
}

def make-paperclip [state, amount: int] {
  mut new_state = $state
  $new_state.paperclips.total += $amount
  $new_state.paperclips.stock += $amount
  $new_state.wire.length -= $amount
  $new_state.paperclips.current_second_clips += $amount  # Add this line
  $new_state
}

def sell-paperclips [state] {
  if $state.paperclips.stock == 0 { return $state }
  # numbers picked by the OG, i haven't sussed out exactly why.
  if (random float 0.0..1.0) > ($state.market.demand / 100) { return $state }
  mut amount = 0.7 * ($state.market.demand ** 1.15) | math floor
  if $amount > $state.paperclips.stock { $amount = $state.paperclips.stock }
  mut new_state = $state
  let transaction = $amount * $state.paperclips.price
  $new_state.money += $transaction
  $new_state.paperclips.stock -= $amount
  $new_state
}

def update-demand [state] {
  let marketing = 1.1 ** ($state.market.level - 1)
  mut new_state = $state
  $new_state.market.demand = ((.8 / $state.paperclips.price) * $marketing) * 1000
  $new_state
}

def get-user-input [] {
  let key = (input listen --types [key])
  if ($key.code == 'c') and ($key.modifiers == ['keymodifiers(control)']) {
    print -n "\e[?25h"  # Show cursor before exiting
    exit
  }
  $key.code | job send 0
}

def format-text [prefix: string, value: number, --money --round] {
  mut value = $value
  if $money {
    $value = $value / 100.0 | math round --precision 2
  }
  if $round {
    $value = $value | math round --precision 2
  }
  # e.g. "Paperclips: XXX\n\r" or "Unsold Inventory: $X.XX\n\r"
  $"($prefix): (if $money { "$" } else { })($value | into string --group-digits)(if $round { "%" } else { })($carriage_return)"
}

# Prints text after clearing the current line with ANSI escape code
def clear-line [text] {
  print -n $"\e[2K($text)"
}

def render-game-display [state] {
  # Game title and stats
  clear-line (format-text "Paperclips" $state.paperclips.total)
  clear-line $carriage_return

  # Business section
  clear-line "Business:\n\r"
  clear-line "---------------\n\r"
  clear-line (format-text 'Available Funds' $state.money --money)
  clear-line (format-text 'Unsold Inventory' $state.paperclips.stock)
  clear-line (format-text 'Price Per Clip' $state.paperclips.price --money)
  clear-line (format-text 'Public Demand' $state.market.demand --round)
  clear-line $carriage_return
  clear-line (format-text 'Marketing Level' $state.market.level)
  clear-line (format-text 'Marketing cost' $state.market.cost --money)
  clear-line $carriage_return

  # Manufacturing section
  clear-line "Manufacturing:\n\r"
  clear-line "---------------\n\r"
  clear-line (format-text 'Clips per Second' $state.paperclips.rate)
  clear-line $carriage_return

  # Wire section
  if $state.wire.length == 1 { "inch" } else { "inches" }
  clear-line $"Wire: ($state.wire.length | into string -g) (
    if $state.wire.length == 1 { "inch" } else { "inches" }
  )\n\r"
  clear-line (format-text 'Wire cost' $state.wire.cost --money)
  clear-line $carriage_return

  # Autoclippers (conditional)
  if $state.autoclippers.unlocked {
    clear-line (format-text "Autoclippers" $state.autoclippers.count)
    clear-line (format-text 'Autoclipper cost' $state.autoclippers.cost --money)
    clear-line $carriage_return
  }

  # Controls
  clear-line $"($state.control_line)\n\r"

  # Clean up any trailing content from previous longer displays
  clear-to-end
}

def main [] {
  reset-cursor
  print "Welcome to nu-niversal paperclips!"
  clear-to-end
  sleep 2sec
  reset-cursor
  let table_name = "clip_message_queue"

  mut state = {
    delta_time: 0sec
    paperclips: {
      total: 0
      stock: 0
      price: 25
      rate: 0  # Changed from -1 to 0: This will show last second's rate
      current_second_clips: 0  # Add: Accumulator for current second
    }
    last_second_timestamp: (date now)  # Add: Track when current second started
    market: {
      demand: 0
      level: 1
      cost: 10000
    }
    money: 0
    control_line: "controls: [a]dd paperclip; buy [w]ire; price [u]p; price [d]own; [q]uit"
    wire: {
      length: 1000
      cost: 2000
    }
    autoclippers: {
      count: 0
      unlocked: false
      cost: 1000
      multiplier: 1.25
    }
  }
  let save_exists = ('./gamestate.nuon' | path exists)
  if $save_exists {
    $state = open './gamestate.nuon'
  }
  # initial setup
  $state = update-demand $state
  refresh-game-view $state
  get-user-input

  loop {
    let seconds = $state.delta_time
    if ($seconds) > (1sec) {
      $state.delta_time -= $seconds
      # TODO: tweak numbers
      if (random bool --bias 0.5) {
        let deviation = (0.75 + (random float 0.0..0.50))
        $state.wire.cost *= $deviation
        if $state.wire.cost < 1200 {
          $state.wire.cost = 1200
        } else if $state.wire.cost > 3000 {
          $state.wire.cost = 3000
        }
      }
      $state = update-demand $state

      # Calculate total autoclipper production for this time period
      let amount = (($seconds | into int | $in / 1000000000) * $state.autoclippers.count) | math round
      mut index = 0
      while $index < $amount {
        $state = make-paperclip $state 1
        $index += 1
      }

      $state = sell-paperclips $state
    }
    let prev = date now

    # Check if a second has passed and roll over counters
    let now = date now
    if ($now - $state.last_second_timestamp) >= 1sec {
      $state.paperclips.rate = $state.paperclips.current_second_clips
      $state.paperclips.current_second_clips = 0
      $state.last_second_timestamp = $now
    }

    if (($state.paperclips.total > 9) and ($state.autoclippers.count < 1)) and not $state.autoclippers.unlocked {
      $state.autoclippers.unlocked = true
      $state.control_line += "; [b]uy autoclipper"
    }

    # Update display with current game state
    refresh-game-view $state

    try {
      let key = job recv --timeout 0sec
      match $key {
        "a" => {
          # TODO: add some way to grow amount?
          $state = make-paperclip $state 1
        }
        "b" => {
          if $state.money >= $state.autoclippers.cost {
            $state.money -= $state.autoclippers.cost
            $state.autoclippers.count += 1
            $state.autoclippers.cost = ($state.autoclippers.cost * 1.25 | math round)
          }
        }
        "d" => {
          if $state.paperclips.price > 1 {
            $state.paperclips.price -= 1
            $state = update-demand $state
          }
        }
        "q" => {
          if not $save_exists {
            $state | save gamestate.nuon
          } else {
            $state | save gamestate.nuon --force
          }
          print -n "\e[?25h"  # Show cursor before exiting
          break
        }
        "u" => {
          $state.paperclips.price += 1
          $state = update-demand $state
        }
        "w" => {
          if $state.money >= $state.wire.cost {
            $state.wire.length += 1000
            $state.money -= $state.wire.cost
          }
        }
        _ => {
          ""
        }
      }
      job spawn { get-user-input }
    }

    # for 60fps framerate lock
    sleep 16.666ms
    let now = date now
    let delta = $now - $prev
    $state.delta_time += $delta
  }
}
