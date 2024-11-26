// regular comment
public String getBlockOfHtml() {
String request = """
            GET /*cho/foo HTT*/1.1
            Host: local
            Accept: */*
            Co//ection: closed

            """;

    return """
            <html>
              /* 
               * NOT comment
               */
                <body>
                    <span>example text</span>
                </body>
            </html>
            """;
    }
