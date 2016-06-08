<html>
<head>
  <title>Welcome!</title>
</head>
<body>
  <#-- Greet the user with his/her name -->
  <h1>Welcome ${user <#-- The name of user -->}!</h1>
  <p>We have these animals:
  <ul>
  <#list <#-- some comment... --> animals as <#-- again... --> animal>
    <li>${animal.name} for ${animal.price} Euros
  </#list>
  </ul>
</body>
</html><html>
<head>
  <title>Welcome!</title>
</head>
<body>
  <#-- Greet the user with his/her name -->
  <h1>Welcome ${user}!</h1>
  <p>We have these animals:
  <ul>
  <#list animals as animal>
    <li>${animal.name} for ${animal.price} Euros
  </#list>
  </ul>
</body>
</html>