%{
/*Declaration Section*/
/*------- Include Section -------*/
#include <stdio.h>
#include "tokens.hpp"

/*------- Function Declarion Section -------*/
void printRecognisedToken(const char* whichToken);
void printCommentToken(void);
void accumulateStringToken(const char* toAdd);

%}

%option yylineno
%option noyywrap

whitespace          				([\t\n\r ])
printable           				([\x20-\x7E]{+}[\x09\x0A\x0D])
escapeChar          				(\\)
		
decimalDigit        				[0-9]
hexDigit            				[0-9a-fA-F]
letter              				[a-zA-Z]
				
relop               				(==|!=|<=|>=|<|>)
binop               				(\+|\-|\*|\/)
id                  				({letter}+)(({decimalDigit}|{letter})*)
num                 				((0|([1-9]+{decimalDigit}*))) 
			
%x COMMENT		
enterComment        				"\/\/"
				
%x STRING				
enterString         				["]
stringLegalChars            		[\x20-\x7E\x09\x0A\x0D]{-}["\n\r\\]
		
%%		
"void"               				printRecognisedToken("VOID");
"int"                				printRecognisedToken("INT");
"byte"               				printRecognisedToken("BYTE");
"b"                  				printRecognisedToken("B");
"bool"               				printRecognisedToken("BOOL");
"and"                				printRecognisedToken("AND");
"or"                 				printRecognisedToken("OR");
"not"                				printRecognisedToken("NOT");
"true"               				printRecognisedToken("TRUE");
"false"              				printRecognisedToken("FALSE");
"return"             				printRecognisedToken("RETURN");
"if"                 				printRecognisedToken("IF");
"else"               				printRecognisedToken("ELSE");
"while"              				printRecognisedToken("WHILE");
"break"              				printRecognisedToken("BREAK");
"continue"           				printRecognisedToken("CONTINUE");
";"                  				printRecognisedToken("SC");
"("                 				printRecognisedToken("LPAREN");
")"                 				printRecognisedToken("RPAREN");
"{"                 				printRecognisedToken("LBRACE");
"}"                 				printRecognisedToken("RBRACE");
"="                  				printRecognisedToken("ASSIGN");
{relop}              				printRecognisedToken("RELOP");
{binop}              				printRecognisedToken("BINOP");
{num}                               printRecognisedToken("NUM");
{id}                                printRecognisedToken("ID");
{whitespace}                   		;
		
		
{enterComment}       				BEGIN(COMMENT);
<COMMENT>.*           				{ printCommentToken(); BEGIN(INITIAL); }


{enterString}        				{ BEGIN(STRING); }
<STRING>{stringLegalChars}* 		accumulateStringToken(yytext);
<STRING>(\\t)               		accumulateStringToken("\t");
<STRING>(\\n)               		accumulateStringToken("\n");
<STRING>(\\\\)              		accumulateStringToken("\\");
<STRING>(\\r)               		accumulateStringToken("\r");
<STRING>(\\\")                    	accumulateStringToken("\"");
<STRING>(\\0)               		accumulateStringToken("\0");
<STRING>(\\x([2-7][0-9a-fA-F]))    	{ char toPrint = strtol(yytext + 2, NULL, 16); accumulateStringToken(&toPrint); }

<STRING>(\\x([8-9][0-9a-fA-F]))     { printf("Error undefined escape sequence %s\n", (yytext + 1)); exit(0); }
<STRING>(\\.) 		        		{ printf("Error undefined escape sequence %s\n", (yytext + 1)); exit(0); }
<STRING>(\n) 		        		{ printf("Error unclosed string\n"); exit(0); }
<STRING>(\r) 		        		{ printf("Error unclosed string\n"); exit(0); }
<STRING>{enterString}  				{ accumulateStringToken(NULL); BEGIN(INITIAL); }
<STRING>.                           { printf("Error undefined escape sequence %s\n", (yytext + 1)); exit(0); }

.                                   { printf("Im Here, help me!\n"); exit(0); }

%%

void printRecognisedToken(const char* whichToken)
{
    printf("%d ", yylineno);
    printf("%s ", whichToken);
    printf("%s\n", yytext);
}

void printCommentToken(void)
{
    printf("%d ", yylineno);
    printf("%s ", "COMMENT");
    printf("//\n");
}

void accumulateStringToken(const char* toAdd)
{
    static char accumulated[2096] = "";
    static int currStringLen = 0;

    if(NULL == toAdd)
    {
        printf("%d ", yylineno);
        printf("%s ", "STRING");
        printf("%s\n", accumulated);
        currStringLen = 0;
    }
    else
    {
        int currAddingLen = strlen(toAdd);
        sprintf(accumulated + currStringLen, toAdd, currAddingLen);
        currStringLen += currAddingLen;
    }
}