#!/usr/local/bin/ruby
# messages.rb - this is a test for the Ruby SLOC counter.
# You should get 110 SLOC for this file.

# Guru module: private messages among players
# Copyright (C) 2001, 2002 Josef Spillner, dr_maux@user.sourceforge.net
# This is used as a test case in SLOCCount, a toolsuite that counts
# source lines of code (SLOC).
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
# To contact David A. Wheeler, see his website at:
#  http://www.dwheeler.com.
# 
# 

# Commands:
# guru do i have any messages
# guru tell grubby nice to meet myself :)
# guru alert grubby

databasedir = ENV['HOME'] + "/.ggz/grubby"

####################################################################################

class GuruMessages
  def initialize
    @msg = Array.new
	@alerts = Array.new
  end
  def add(fromplayer, player, message)
    @entry = Array.new
	newmessage = (fromplayer + " said: " + message.join(" ")).split(" ")
    @entry << player << newmessage
    @msg.push(@entry)
	print "OK, I make sure he gets the message."
	$stdout.flush
	sleep 1
  end
  def tell(player)
    len = @msg.length
	a = 0
    for i in 0..len
	  unless @msg[len-i] == nil
	    print @msg[len-i][1][0..@msg[len-i][1].length - 1].join(" ") + "\n" if player == @msg[len-i][0]
		if player == @msg[len-i][0]
  	      @msg.delete_at(len-i)
		  a = 1
		end
	  end
	end
	if a == 0
	  print "Sorry " + player + ", I guess you're not important enough to get any messages."
	end
	$stdout.flush
	sleep 1
  end
  def alert(fromplayer, player)
    @entry = Array.new << fromplayer << player
    @alerts.push(@entry)
	print "OK, I alert " + player + " when I see him."
	$stdout.flush
	sleep 1
  end
  def trigger(player)
    len = @alerts.length
	a = 0
    for i in 0..len
	  unless @alerts[len-i] == nil
  	    if player == @alerts[len-i][0]
	      print player + ": ALERT from " + @alerts[len-i][1] + "\n"
	      @alerts.delete_at(len-i)
		  a = 1
		end
	  end
	end
	if a == 1
	  $stdout.flush
	  sleep 1
	  return 1
	end
	return 0
  end
end

input = $stdin.gets.chomp.split(/\ /)

mode = 0
if (input[1] == "do") && (input[2] == "i") && (input[3] == "have") &&
  (input[4] == "any") && (input[5] == "messages")
  mode = 1
  player = ARGV[0]
end
if (input[1] == "tell")
  mode = 2
  fromplayer = ARGV[0]
  player = input[2]
  message = input[3..input.length]
end
if(input[1] == "alert")
  mode = 3
  fromplayer = ARGV[0]
  player = input[2]
end

m = nil
begin
  File.open(databasedir + "/messages") do |f|
    m = Marshal.load(f)
  end
rescue
  m = GuruMessages.new
end

if mode == 0
  ret = m.trigger ARGV[0]
  if ret == 0
    exit
  end
end
if mode == 1
  if player != nil
    m.tell player
  else
    print "If you mind telling me who you are?"
    $stdout.flush
	sleep 1
  end
end
if mode == 2
  m.add fromplayer, player, message
end
if mode == 3
  m.alert fromplayer, player
end

File.open(databasedir + "/messages", "w+") do |f|
  Marshal.dump(m, f)
end

