"http://smalltalk.gnu.org/blog/bonzinip/captcha-simplest-gst-external-module"
DLD addModule: 'GD'.
FileStream fileIn: 'GST_DIR/share/smalltalk/GD/GD.st'.

"A useful method... (will be in 3.0.1)"
SequenceableCollection extend [
    atRandom [
        ^self at: (Random between: 1 and: self size)
    ]
]

"Make a four character captcha."
fontPath := '/usr/share/fonts/bitstream-vera/Vera.ttf'.
authChars := '0123456789'.
authChars := authChars, 'abcdefghijklmnopqrstuvwxyz'.
authChars := authChars, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.

authString := String streamContents: [ :s |.
   4 timesRepeat: [ s nextPut: authChars atRandom ]].

GD
    imageString: authString
    font: fontPath
    foreground: #[255 255 255]
    background: #[0 0 0]
    size: 40
    to: 'captcha.png'.
