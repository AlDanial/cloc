// https://github.com/openharmony/docs/blob/master/en/application-dev/quick-start/start-with-ets.md
// index.ets
@Entry
@Component
struct Index {
  @State message: string = 'Hello World'

  build() {
    Row() {
/*
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
*/
    }
    .height('100%')
  }
}
