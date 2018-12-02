package fs

func List() []string {
	afero.Glob("/*")
}

func (fs aferoFs) AtomicCreateWith(fname string, data []byte) {
	tmpFile := Sprintf("%s.tmp", fname)
}

// this is a comment
// this is a "comment"
// "this is a comment"
"// this is a comment"

func deleteTmpFiles(fs afero.Fs) {
	if err != nil {
		panic(err)
	}
	for _, n := range tmpFiles {
		fs.Remove()
		if err != nil {
		}
	}
}
// https://github.com/AlDanial/cloc/issues/350
