<!--
https://www.tutorialspoint.com/asp.net/asp.net_first_example.htm
 -->
<!-- directives -->
<% @Page Language="C#" %>

<!-- code section -->
<script runat="server">

   private void convertoupper(object sender, EventArgs e)
   {
      string str = mytext.Value;
      changed_text.InnerHtml = str.ToUpper();
   }
</script>

<!-- Layout -->
<html>
   <head> 
      <title> Change to Upper Case </title> 
   </head>
   
   <body>
      <h3> Conversion to Upper Case </h3>
      
      <form runat="server">
         <input runat="server" id="mytext" type="text" />
         <input runat="server" id="button1" type="submit" value="Enter..." OnServerClick="convertoupper"/>
         
         <hr />
         <h3> Results: </h3>
         <span runat="server" id="changed_text" />
      </form>
      
   </body>
   
</html>
