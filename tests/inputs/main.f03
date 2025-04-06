! Measure units:
! - *_px - pixels
! - *_cl - cells
! - *_rl - relative (fraction of width, height, cell size, etc)

program main
  use iso_c_binding, only: c_int, c_int32_t, C_NULL_CHAR, C_NULL_PTR, c_loc
  use raylib
  use raymath
  use game
  use ai
  use ui
  implicit none

  type :: Particle
     real, dimension(2) :: position, velocity
     integer(c_int32_t) :: color
     real :: size, lt_sec, lt_t
  end type Particle

  integer, parameter :: font_size = 128
  real,    parameter :: particle_min_mag      = 50.0
  real,    parameter :: particle_max_mag      = 400.0
  real,    parameter :: particle_min_size     = 2.0
  real,    parameter :: particle_max_size     = 5.0
  real,    parameter :: particle_min_lt       = 0.5
  real,    parameter :: particle_max_lt       = 0.8
  integer, parameter :: particles_burst_count = 100

  real    :: dt
  real    :: board_x_px, board_y_px, board_boundary_width, board_boundary_height, board_size_px, cell_size_px

  integer,dimension(board_size_cl, board_size_cl) :: board

  integer :: current_player
  type(TLine) :: final_line
  integer :: state
  type(Font) :: game_font
  type(Particle) :: particles(particles_burst_count*board_size_cl*board_size_cl + 10)
  type(Sound) :: click_sound
  logical :: click_played_on_previous_frame, click_played_on_this_frame

  logical, dimension(2) :: ai_checkboxes
  integer :: i

  enum, bind(C)
     enumerator :: STATE_GAME = 0
     enumerator :: STATE_WON
     enumerator :: STATE_TIE
  end enum

  ai_checkboxes(CELL_CROSS) = .false.
  ai_checkboxes(CELL_KNOTT) = .true.
  do i=1,size(particles)
     particles(i)%lt_t = 0.0
  end do

  call restart_game()

  call set_config_flags(FLAG_WINDOW_RESIZABLE)
  ! TODO: draw_rectangle_rounded, draw_circle_v, etc (basically anything that renders circles) has rendering artifacts that make some of the pixels of the background visible when FLAG_MSAA_4X_HINT is enabled
  ! This could be a bug of Raylib. The implementations may not be taking MSAA into account.
  call set_config_flags(FLAG_MSAA_4X_HINT)
  call init_window(16*80, 9*80, "Fortran GOTY"//C_NULL_CHAR)
  call init_audio_device()
  call set_target_fps(60)

  ! TODO: set the working directory to where the executable is located
  ! This is needed to be able to locate the assets properly
  game_font = load_font_ex("./fonts/Alegreya-Regular.ttf"//C_NULL_CHAR, font_size, C_NULL_PTR, 0)
  call set_texture_filter(game_font%texture, TEXTURE_FILTER_BILINEAR)
  click_sound = load_sound("./sounds/misc_26_fixed.ogg"//C_NULL_CHAR)

  do while (.not. window_should_close())
     click_played_on_previous_frame = click_played_on_this_frame
     click_played_on_this_frame = .false.
     call begin_drawing()
       call begin_screen_fitting()
         call clear_background(background_color)

         dt = get_frame_time()
         board_boundary_width  = screen_width_px*2/3
         board_boundary_height = screen_height_px

         if (board_boundary_width > board_boundary_height) then
            board_size_px = board_boundary_height
            board_x_px = real(board_boundary_width)/2 - board_size_px/2
            board_y_px = 0
         else
            board_size_px = board_boundary_width
            board_x_px = 0
            board_y_px = real(board_boundary_height)/2 - board_size_px/2
         end if

         board_x_px = board_x_px + board_size_px*board_margin_rl
         board_y_px = board_y_px + board_size_px*board_margin_rl
         board_size_px = board_size_px - board_size_px*board_margin_rl*2

         cell_size_px = board_size_px/board_size_cl

         select case (state)
         case (STATE_GAME)
            call render_game_state()
         case (STATE_WON)
            call render_won_state()
         case (STATE_TIE)
            call render_tie_state()
         end select

         call render_ai_checkboxes(rectangle( &
              board_boundary_width, &
              0, &
              screen_width_px - board_boundary_width, &
              board_boundary_height))
       call end_screen_fitting()
     call end_drawing()
  end do

contains
  pure function lerp(a, b, t) result(c)
    real, intent(in) :: a, b, t
    real :: c
    c = a + (b - a)*t
  end function lerp

  subroutine spawn_random_particles_along_line(start, end, count, color)
    real, dimension(2),  intent(in) :: start, end
    integer,             intent(in) :: count
    integer(c_int32_t),  intent(in) :: color

    real, dimension(2) :: position
    real :: t
    integer :: i

    do i=1,count
       call random_number(t)
       position = start + (end - start)*t
       call spawn_random_particle_at(position, color)
    end do
  end subroutine spawn_random_particles_along_line

  subroutine spawn_random_particles_in_region(region, count, color)
    type(Rectangle),intent(in) :: region
    integer,intent(in) :: count
    integer(c_int32_t),intent(in) :: color

    real, dimension(2) :: position, t
    integer :: i

    do i=1,count
       call random_number(t)
       position = [region%x, region%y] + [region%width, region%height]*t
       call spawn_random_particle_at(position, color)
    end do
  end subroutine spawn_random_particles_in_region

  subroutine spawn_random_particle_at(position,color)
    real, dimension(2), intent(in) :: position
    integer(c_int32_t), intent(in) :: color

    type(Particle) :: p
    real :: angle, mag, t
    real, parameter :: pi = 4.D0*DATAN(1.D0)

    p%position = position

    call random_number(t)
    angle = 2.0*pi*t

    call random_number(t)
    mag = lerp(particle_min_mag, particle_max_mag, t)
    p%velocity = [cos(angle), sin(angle)]*mag

    p%color = color

    call random_number(t)
    p%size = lerp(particle_min_size, particle_max_size, t)

    call random_number(t)
    p%lt_sec = lerp(particle_min_lt, particle_max_lt, t)
    p%lt_t = 1.0

    call spawn_particle(p)
  end subroutine spawn_random_particle_at

  subroutine spawn_particle(p)
    type(Particle),intent(in) :: p
    type(Particle) :: pi
    integer :: i

    do i=1,size(particles)
       pi = particles(i)
       if (pi%lt_t <= 0.0) then
          particles(i) = p
          return
       end if
    end do
  end subroutine spawn_particle

  subroutine render_particles(dt)
    real,intent(in) :: dt
    type(Particle) :: p
    integer :: i

    do i=1,size(particles)
       p = particles(i)
       if (p%lt_t > 0.0) then
          particles(i)%velocity = p%velocity*0.98
          particles(i)%position = p%position + particles(i)%velocity*dt
          particles(i)%lt_t = (p%lt_t*p%lt_sec - dt)/p%lt_sec
          call draw_circle_v(Vector2(p%position), p%size, color_alpha(p%color, p%lt_t))
       end if
    end do
  end subroutine render_particles

  subroutine render_ai_checkboxes(boundary)
    real,parameter :: checkbox_width_rl = 0.45
    real,parameter :: checkbox_height_rl = 0.10
    real,parameter :: checkbox_padding_rl = 0.05
    type(Rectangle),intent(in) :: boundary

    type(Rectangle) :: cross_boundary, knott_boundary
    real :: checkbox_height_px, checkbox_padding_px
    type(Vector2) :: text_pos, text_size

    checkbox_height_px = boundary%height*checkbox_height_rl
    checkbox_padding_px = boundary%height*checkbox_padding_rl

    cross_boundary%width = boundary%width*checkbox_width_rl
    cross_boundary%height = checkbox_height_px
    cross_boundary%x = boundary%x + boundary%width/2 - cross_boundary%width/2
    cross_boundary%y = boundary%y + boundary%height/2 - checkbox_height_px - checkbox_padding_px*0.5

    knott_boundary%width = boundary%width*checkbox_width_rl
    knott_boundary%height = checkbox_height_px
    knott_boundary%x = boundary%x + boundary%width/2 - knott_boundary%width/2
    knott_boundary%y = boundary%y + boundary%height/2 + checkbox_padding_px*0.5

    text_size = measure_text_ex(game_font, "AI"//C_NULL_CHAR, checkbox_height_px, 0.0)
    text_pos = Vector2( &
         [cross_boundary%x, &
         ! cross_boundary%x + cross_boundary%width/2 - text_size%x/2, &
         cross_boundary%y - checkbox_height_px - checkbox_padding_px])
    call draw_text_ex(game_font, "AI"//C_NULL_CHAR, text_pos,checkbox_height_px, 0.0, restart_button_color)

    call checkbox(cross_checkbox_id,CELL_CROSS,cross_boundary,ai_checkboxes(CELL_CROSS))
    call checkbox(knott_checkbox_id,CELL_KNOTT,knott_boundary,ai_checkboxes(CELL_KNOTT))
  end subroutine render_ai_checkboxes

  subroutine render_tie_state()
    call render_board(board_x_px, board_y_px, board_size_px, board)
    call render_particles(dt)

    if (restart_button(game_font, board_x_px, board_y_px, board_size_px)) then
      call restart_game()
    end if
  end subroutine render_tie_state

  subroutine render_won_state()
    call render_board(board_x_px, board_y_px, board_size_px, board)
    call render_particles(dt)

    call strikethrough(final_line, Square([board_x_px, board_y_px], board_size_px))
    if (restart_button(game_font, board_x_px, board_y_px, board_size_px)) then
       call restart_game()
    end if
  end subroutine render_won_state

  subroutine render_game_state()
    integer           :: x_cl, y_cl
    real              :: board_cell_size
    real,dimension(2) :: start, end

    board_cell_size = board_size_px/board_size_cl

    if (ai_checkboxes(current_player)) then
       call render_board(board_x_px, board_y_px, board_size_px, board)

       if (.not. ai_next_move(board, current_player, x_cl, y_cl)) then
          board(x_cl, y_cl) = current_player
          if (.not. click_played_on_previous_frame) then
             call play_sound(click_sound)
             click_played_on_this_frame = .true.
          end if
          if (player_won(board, CELL_CROSS, [x_cl, y_cl], final_line)) then
             state = STATE_WON
             call map_tline_on_screen(final_line, Square([board_x_px, board_y_px], board_size_px), start, end)
             call spawn_random_particles_along_line(start, end, particles_burst_count*3, strikethrough_color)
             return
          end if
          if (player_won(board, CELL_KNOTT, [x_cl, y_cl], final_line)) then
             state = STATE_WON
             call map_tline_on_screen(final_line, Square([board_x_px, board_y_px], board_size_px), start, end)
             call spawn_random_particles_along_line(start, end, particles_burst_count*3, strikethrough_color)
             return
          end if
          call spawn_random_particles_in_region( &
               Rectangle(board_x_px + (x_cl - 1)*board_cell_size,   &
                         board_y_px + (y_cl - 1)*board_cell_size,   &
                         board_cell_size,        &
                         board_cell_size),       &
               particles_burst_count,                               &
               shape_colors(current_player))
          current_player = 3 - current_player
          if (board_full(board)) then
             state = STATE_TIE
             return
          end if
       else
          state = STATE_TIE
          return
       end if
    else
       if (render_board_clickable(board_x_px, board_y_px, board_size_px, board, x_cl, y_cl)) then
          board(x_cl, y_cl) = current_player
          if (.not. click_played_on_previous_frame) then
             call play_sound(click_sound)
             click_played_on_this_frame = .true.
          end if
          if (player_won(board, CELL_CROSS, [x_cl, y_cl], final_line)) then
             state = STATE_WON
             call map_tline_on_screen(final_line, Square([board_x_px, board_y_px], board_size_px), start, end)
             call spawn_random_particles_along_line(start, end, particles_burst_count*3, strikethrough_color)
             return
          end if
          if (player_won(board, CELL_KNOTT, [x_cl, y_cl], final_line)) then
             state = STATE_WON
             call map_tline_on_screen(final_line, Square([board_x_px, board_y_px], board_size_px), start, end)
             call spawn_random_particles_along_line(start, end, particles_burst_count*3, strikethrough_color)
             return
          end if
          call spawn_random_particles_in_region( &
               Rectangle(board_x_px + (x_cl - 1)*board_cell_size,   &
                         board_y_px + (y_cl - 1)*board_cell_size,   &
                         board_cell_size,        &
                         board_cell_size),       &
               particles_burst_count,                       &
               shape_colors(current_player))
          current_player = 3 - current_player
          if (board_full(board)) then
             state = STATE_TIE
             return
          end if
       end if
    end if
    call render_particles(dt)
  end subroutine render_game_state

  subroutine restart_game()
    board(:,:) = 0
    state = STATE_GAME
    current_player = CELL_CROSS
  end subroutine restart_game
end program

! # Roadmap
! - TODO: customizable board size
! - TODO: sound volume controls
! - TODO: accessibility: control via keyboard
