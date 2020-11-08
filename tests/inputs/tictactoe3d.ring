# from https://raw.githubusercontent.com/ring-lang/ring/master/applications/tictactoe3d/tictactoe3d.ring

/*
**
**	Game  			 : TicTacToe 3D 
**	Date   			 : 2017/08/30
**  	Author 			 : Mahmoud Fayed <msfclipper@yahoo.com>
**
**	Note :  The CheckWinner() function is 
**			written by Abdulrahman Mahmoud 
**			See ring/applications/tictactoe
**
*/

# Load Libraries
	load "gamelib.ring"		# RingAllegro Library
	load "opengl21lib.ring"		# RingOpenGL  Library

#==============================================================
# To Support MacOS X
	al_run_main()	
	func al_game_start 	# Called by al_run_main()
		main()		# Now we call our main function
#==============================================================

func main
	new TicTacToe3D {
		start()
	}

class TicTacToe3D from GameLogic

	FPS	= 120
	TITLE	= "TicTacToe 3D"
	ICON	= "image/o.png"

	oBackground	= new GameBackground
	oGameSound	= new GameSound
	oGameCube	= new GameCube
	oGameOver	= new GameOver
	oGameInterface	= new GameInterface 

	func loadresources
		oGameOver.loadresources()
		oGameSound.loadresources()
		oBackGround.loadresources()
		oGameCube.loadresources()

	func destroyResources
		oGameOver.destroyResources()
		oGameSound.destroyResources()
		oBackGround.destroyResources()
		oGameCube.destroyResources()

	func drawScene
		oBackground.update()
		oGameInterface.update(self)

	func MouseClickEvent
		oGameInterface.MouseClickEvent(self)
