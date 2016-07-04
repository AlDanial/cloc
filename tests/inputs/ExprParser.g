// https://github.com/apache/drill/raw/master/logical/src/main/antlr3/org/apache/drill/common/expression/parser/ExprParser.g
parser grammar ExprParser;

options{
  output=AST;
  language=Java;
  tokenVocab=ExprLexer;
  backtrack=true;
  memoize=true;
}



@header {
/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.drill.common.expression.parser;
  
//Explicit import...
import org.antlr.runtime.BitSet;
import java.util.*;
import org.apache.drill.common.expression.*;
import org.apache.drill.common.expression.PathSegment.NameSegment;
import org.apache.drill.common.expression.PathSegment.ArraySegment;
import org.apache.drill.common.types.*;
import org.apache.drill.common.types.TypeProtos.*;
import org.apache.drill.common.types.TypeProtos.DataMode;
import org.apache.drill.common.types.TypeProtos.MajorType;
import org.apache.drill.common.exceptions.ExpressionParsingException;
}

@members{
  private String fullExpression;
  private int tokenPos;

  public static void p(String s){
    System.out.println(s);
  }
  
  public ExpressionPosition pos(Token token){
    return new ExpressionPosition(fullExpression, token.getTokenIndex());
  }
  
  @Override    
  public void displayRecognitionError(String[] tokenNames, RecognitionException e) {
	String hdr = getErrorHeader(e);
    String msg = getErrorMessage(e, tokenNames);
    throw new ExpressionParsingException("Expression has syntax error! " + hdr + ":" + msg);
  }
}

parse returns [LogicalExpression e]
  :  expression EOF {
    $e = $expression.e; 
    if(fullExpression == null) fullExpression = $expression.text;
    tokenPos = $expression.start.getTokenIndex();
  }
  ;
 
functionCall returns [LogicalExpression e]
  :  Identifier OParen exprList? CParen {$e = FunctionCallFactory.createExpression($Identifier.text, pos($Identifier), $exprList.listE);  }
  ;

convertCall returns [LogicalExpression e]
  :  Convert OParen expression Comma String CParen
      { $e = FunctionCallFactory.createConvert($Convert.text, $String.text, $expression.e, pos($Convert));}
  ;

castCall returns [LogicalExpression e]
	@init{
  	  List<LogicalExpression> exprs = new ArrayList<LogicalExpression>();
	  ExpressionPosition p = null;
	}  
  :  Cast OParen expression As dataType repeat? CParen 
      {  if ($repeat.isRep!=null && $repeat.isRep.compareTo(Boolean.TRUE)==0)
           $e = FunctionCallFactory.createCast(TypeProtos.MajorType.newBuilder().mergeFrom($dataType.type).setMode(DataMode.REPEATED).build(), pos($Cast), $expression.e);
         else
           $e = FunctionCallFactory.createCast($dataType.type, pos($Cast), $expression.e);}
  ;

repeat returns [Boolean isRep]
  : Repeat { $isRep = Boolean.TRUE;}
  ;

dataType returns [MajorType type]
	: numType  {$type =$numType.type;}
	| charType {$type =$charType.type;}
	| dateType {$type =$dateType.type;}
	| booleanType {$type =$booleanType.type;}
	;

booleanType returns [MajorType type]
	: BIT { $type = Types.required(TypeProtos.MinorType.BIT); }
	;

numType returns [MajorType type]
	: INT    { $type = Types.required(TypeProtos.MinorType.INT); }
	| BIGINT { $type = Types.required(TypeProtos.MinorType.BIGINT); }
	| FLOAT4 { $type = Types.required(TypeProtos.MinorType.FLOAT4); }
	| FLOAT8 { $type = Types.required(TypeProtos.MinorType.FLOAT8); }
	| DECIMAL9 OParen precision Comma scale CParen { $type = TypeProtos.MajorType.newBuilder().setMinorType(TypeProtos.MinorType.DECIMAL9).setMode(DataMode.REQUIRED).setPrecision($precision.value.intValue()).setScale($scale.value.intValue()).build(); }
	| DECIMAL18 OParen precision Comma scale CParen { $type = TypeProtos.MajorType.newBuilder().setMinorType(TypeProtos.MinorType.DECIMAL18).setMode(DataMode.REQUIRED).setPrecision($precision.value.intValue()).setScale($scale.value.intValue()).build(); }
	| DECIMAL28DENSE OParen precision Comma scale CParen { $type = TypeProtos.MajorType.newBuilder().setMinorType(TypeProtos.MinorType.DECIMAL28DENSE).setMode(DataMode.REQUIRED).setPrecision($precision.value.intValue()).setScale($scale.value.intValue()).build(); }
	| DECIMAL28SPARSE OParen precision Comma scale CParen { $type = TypeProtos.MajorType.newBuilder().setMinorType(TypeProtos.MinorType.DECIMAL28SPARSE).setMode(DataMode.REQUIRED).setPrecision($precision.value.intValue()).setScale($scale.value.intValue()).build(); }
	| DECIMAL38DENSE OParen precision Comma scale CParen { $type = TypeProtos.MajorType.newBuilder().setMinorType(TypeProtos.MinorType.DECIMAL38DENSE).setMode(DataMode.REQUIRED).setPrecision($precision.value.intValue()).setScale($scale.value.intValue()).build(); }
	| DECIMAL38SPARSE OParen precision Comma scale CParen { $type = TypeProtos.MajorType.newBuilder().setMinorType(TypeProtos.MinorType.DECIMAL38SPARSE).setMode(DataMode.REQUIRED).setPrecision($precision.value.intValue()).setScale($scale.value.intValue()).build(); }
	;

charType returns [MajorType type]
	:  VARCHAR typeLen {$type = TypeProtos.MajorType.newBuilder().setMinorType(TypeProtos.MinorType.VARCHAR).setMode(DataMode.REQUIRED).setWidth($typeLen.length.intValue()).build(); }
	|  VARBINARY typeLen {$type = TypeProtos.MajorType.newBuilder().setMinorType(TypeProtos.MinorType.VARBINARY).setMode(DataMode.REQUIRED).setWidth($typeLen.length.intValue()).build();}	
	;

precision returns [Integer value]
    : Number {$value = Integer.parseInt($Number.text); }
    ;

scale returns [Integer value]
    : Number {$value = Integer.parseInt($Number.text); }
    ;

dateType returns [MajorType type]
    : DATE { $type = Types.required(TypeProtos.MinorType.DATE); }
    | TIMESTAMP   { $type = Types.required(TypeProtos.MinorType.TIMESTAMP); }
    | TIME   { $type = Types.required(TypeProtos.MinorType.TIME); }
    | TIMESTAMPTZ   { $type = Types.required(TypeProtos.MinorType.TIMESTAMPTZ); }
    | INTERVAL { $type = Types.required(TypeProtos.MinorType.INTERVAL); }
    | INTERVALYEAR { $type = Types.required(TypeProtos.MinorType.INTERVALYEAR); }
    | INTERVALDAY { $type = Types.required(TypeProtos.MinorType.INTERVALDAY); }
    ;

typeLen returns [Integer length]
    : OParen Number CParen {$length = Integer.parseInt($Number.text);}
    ;

ifStatement returns [LogicalExpression e]
	@init {
	  IfExpression.Builder s = IfExpression.newBuilder();
	}
	@after {
	  $e = s.build();
	}  
  :  i1=ifStat {s.setIfCondition($i1.i); s.setPosition(pos($i1.start)); } (elseIfStat { s.setIfCondition($elseIfStat.i); } )* Else expression { s.setElse($expression.e); }End
  ;

ifStat returns [IfExpression.IfCondition i]
  : If e1=expression Then e2=expression { $i = new IfExpression.IfCondition($e1.e, $e2.e); }
  ;
elseIfStat returns [IfExpression.IfCondition i]
  : Else If e1=expression Then e2=expression { $i = new IfExpression.IfCondition($e1.e, $e2.e); }
  ;

caseStatement returns [LogicalExpression e]
	@init {
	  IfExpression.Builder s = IfExpression.newBuilder();
	}
	@after {
	  $e = s.build();
	}  
  : Case (caseWhenStat {s.setIfCondition($caseWhenStat.e); }) + caseElseStat { s.setElse($caseElseStat.e); } End
  ;
  
caseWhenStat returns [IfExpression.IfCondition e]
  : When e1=expression Then e2=expression {$e = new IfExpression.IfCondition($e1.e, $e2.e); }
  ;
  
caseElseStat returns [LogicalExpression e]
  : Else expression {$e = $expression.e; }
  ;
  
exprList returns [List<LogicalExpression> listE]
	@init{
	  $listE = new ArrayList<LogicalExpression>();
	}
  :  e1=expression {$listE.add($e1.e); } (Comma e2=expression {$listE.add($e2.e); } )*
  ;

expression returns [LogicalExpression e]  
  :  ifStatement {$e = $ifStatement.e; }
  |  caseStatement {$e = $caseStatement.e; }
  |  condExpr {$e = $condExpr.e; }
  ;

condExpr returns [LogicalExpression e]
  :  orExpr {$e = $orExpr.e; }
  ;

orExpr returns [LogicalExpression e]
	@init{
	  List<LogicalExpression> exprs = new ArrayList<LogicalExpression>();
	  ExpressionPosition p = null;
	}
	@after{
	  if(exprs.size() == 1){
	    $e = exprs.get(0);
	  }else{
	    $e = FunctionCallFactory.createBooleanOperator("or", p, exprs);
	  }
	}
  :  a1=andExpr { exprs.add($a1.e); p = pos( $a1.start );} (Or a2=andExpr { exprs.add($a2.e); })*
  ;

andExpr returns [LogicalExpression e]
	@init{
	  List<LogicalExpression> exprs = new ArrayList<LogicalExpression>();
	  ExpressionPosition p = null;
	}
	@after{
	  if(exprs.size() == 1){
	    $e = exprs.get(0);
	  }else{
	    $e = FunctionCallFactory.createBooleanOperator("and", p, exprs);
	  }
	}
  :  e1=equExpr { exprs.add($e1.e); p = pos( $e1.start );  } ( And e2=equExpr { exprs.add($e2.e);  })*
  ;

equExpr returns [LogicalExpression e]
	@init{
	  List<LogicalExpression> exprs = new ArrayList<LogicalExpression>();
	  List<String> cmps = new ArrayList();
	  ExpressionPosition p = null;
	}
	@after{
	  $e = FunctionCallFactory.createByOp(exprs, p, cmps);
	}
  :  r1=relExpr { exprs.add($r1.e); p = pos( $r1.start );
    } ( cmpr= ( Equals | NEquals ) r2=relExpr {exprs.add($r2.e); cmps.add($cmpr.text); })*
  ;

relExpr returns [LogicalExpression e]
  :  left=addExpr {$e = $left.e; } (cmpr = (GTEquals | LTEquals | GT | LT) right=addExpr {$e = FunctionCallFactory.createExpression($cmpr.text, pos($left.start), $left.e, $right.e); } )?
  ;

addExpr returns [LogicalExpression e]
	@init{
	  List<LogicalExpression> exprs = new ArrayList<LogicalExpression>();
	  List<String> ops = new ArrayList();
	  ExpressionPosition p = null;
	}
	@after{
	  $e = FunctionCallFactory.createByOp(exprs, p, ops);
	}
  :  m1=mulExpr  {exprs.add($m1.e); p = pos($m1.start); } ( op=(Plus|Minus) m2=mulExpr {exprs.add($m2.e); ops.add($op.text); })* 
  ;

mulExpr returns [LogicalExpression e]
	@init{
	  List<LogicalExpression> exprs = new ArrayList<LogicalExpression>();
	  List<String> ops = new ArrayList();
	  ExpressionPosition p = null;
	}
	@after{
	  $e = FunctionCallFactory.createByOp(exprs, p, ops);
	}
  :  p1=xorExpr  {exprs.add($p1.e); p = pos($p1.start);} (op=(Asterisk|ForwardSlash|Percent) p2=xorExpr {exprs.add($p2.e); ops.add($op.text); } )*
  ;

xorExpr returns [LogicalExpression e]
	@init{
	  List<LogicalExpression> exprs = new ArrayList<LogicalExpression>();
	  List<String> ops = new ArrayList();
	  ExpressionPosition p = null;
	}
	@after{
	  $e = FunctionCallFactory.createByOp(exprs, p, ops);
	}
  :  u1=unaryExpr {exprs.add($u1.e); p = pos($u1.start);} (Caret u2=unaryExpr {exprs.add($u2.e); ops.add($Caret.text);} )*
  ;
  
unaryExpr returns [LogicalExpression e]
  :  sign=(Plus|Minus)? Number {$e = ValueExpressions.getNumericExpression($sign.text, $Number.text, pos(($sign != null) ? $sign : $Number)); }
  |  Minus atom {$e = FunctionCallFactory.createExpression("u-", pos($Minus), $atom.e); }
  |  Excl atom {$e= FunctionCallFactory.createExpression("!", pos($Excl), $atom.e); }
  |  atom {$e = $atom.e; }
  ;

atom returns [LogicalExpression e]
  :  Bool {$e = new ValueExpressions.BooleanExpression($Bool.text, pos($Bool)); }
  |  lookup {$e = $lookup.e; }
  ;

pathSegment returns [NameSegment seg]
  : s1=nameSegment {$seg = $s1.seg;}
  ;

nameSegment returns [NameSegment seg]
  : QuotedIdentifier ( (Period s1=pathSegment) | s2=arraySegment)? {$seg = new NameSegment($QuotedIdentifier.text, ($s1.seg == null ? $s2.seg : $s1.seg) ); }
  | Identifier ( (Period s1=pathSegment) | s2=arraySegment)? {$seg = new NameSegment($Identifier.text, ($s1.seg == null ? $s2.seg : $s1.seg) ); }
  ;
  
arraySegment returns [PathSegment seg]
  :  OBracket Number CBracket ( (Period s1=pathSegment) | s2=arraySegment)? {$seg = new ArraySegment($Number.text, ($s1.seg == null ? $s2.seg : $s1.seg) ); }
  ;


lookup returns [LogicalExpression e]
  :  functionCall {$e = $functionCall.e ;}
  | convertCall {$e = $convertCall.e; }
  | castCall {$e = $castCall.e; }
  | pathSegment {$e = new SchemaPath($pathSegment.seg, pos($pathSegment.start) ); }
  | String {$e = new ValueExpressions.QuotedString($String.text, pos($String) ); }
  | OParen expression CParen  {$e = $expression.e; }
  | SingleQuote Identifier SingleQuote {$e = new SchemaPath($Identifier.text, pos($Identifier) ); }
  ;
  
  
  
