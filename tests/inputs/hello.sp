#!/usr/local/bin/spar
-- http://www.sparforte.com/sparforte21/examples/hello.html

-- Hello world in a quick and scripty way
? "Hello world!";

-- Hello world in a do it again way
?%;

-- Hello world in a Bourne shell way
echo Hello world!;

-- Hello world in an AdaScript parameter shell way
echo( "Hello world!" );

-- Hello world in a ISO standard, scalable, structured way
put_line( "Hello world!" );

-- Hello world in a PostgreSQL database way
db.connect( "ken" );
select 'Hello world!';
db.disconnect;
