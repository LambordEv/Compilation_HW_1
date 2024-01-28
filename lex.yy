%{
/*Declaration Section*/
/*------- Include Section -------*/
#include <stdio.h>
#include "tokens.hpp"
#include "hw1.cpp"

/*------- Function Declarion Section -------*/
void printString(const char* toPrint);
void printRecognisedToken(tokentype whichToken);

%}

%option yylineno
%option noyywrap

whitespace          				([\t\n\r ])
printable           				([\x20-\x7E\x09\x0A\x0D])
printableExceptIlligal				([\x20-\x7E\x09\x0A\x0D^\\"\n\r])
escapeChar          				(\\)
		
decimalDigit        				([0-9])
hexDigit            				([0-9a-fA-F])
letter              				([a-zA-Z])
				
relop               				(==|!=|<=|>=|<|>)
binop               				(\+|\-|\*|\/)
id                  				(letter+decimalDigit*letter*)
num                 				(0|[1-9]+decimalDigit*)
		
		
%x COMMENT		
enterComment        				(\/\/)
				
%x STRING				
enterString         				(")
stringLegalChars            		([^\\\n\r"])
legalEscaping       				((\\\\)|(\\")|(\\n)|(\\r)|(\\t)|(\\0)|(\xhexDigit{2}))
		
%%		
(void)               				printRecognisedToken(VOID);
(int)                				printRecognisedToken(INT);
(byte)               				printRecognisedToken(BYTE);
(b)                  				printRecognisedToken(B);
(bool)               				printRecognisedToken(BOOL);
(and)                				printRecognisedToken(AND);
(or)                 				printRecognisedToken(OR);
(not)                				printRecognisedToken(NOT);
(true)               				printRecognisedToken(TRUE);
(false)              				printRecognisedToken(FALSE);
(return)             				printRecognisedToken(RETURN);
(if)                 				printRecognisedToken(IF);
(else)               				printRecognisedToken(ELSE);
(while)              				printRecognisedToken(WHILE);
(break)              				printRecognisedToken(BREAK);
(continue)           				printRecognisedToken(CONTINUE);
(;)                  				printRecognisedToken(SC);
(\()                 				printRecognisedToken(LPAREN);
(\))                 				printRecognisedToken(RPAREN);
(\{)                 				printRecognisedToken(LBRACE);
(\})                 				printRecognisedToken(RBRACE);
(=)                  				printRecognisedToken(ASSIGN);
(relop)              				printRecognisedToken(RELOP);
(binop)              				printRecognisedToken(BINOP);
(whitespace)+               		;               
		
		
(enterComment)       				BEGIN(COMMENT);
<COMMENT>.           				{ printRecognisedToken(COMMENT); BEGIN(INITIAL); }


(enterString)        				{ BEGIN(STRING); printString(NULL); }
<STRING>(stringLegalChars*) 		printf("%s\n", yytext);
<STRING>(\\t)               		printf("\t");
<STRING>(\\n)               		printf("\n");
<STRING>(\\\\)              		printf("\\");
<STRING>(\\r)               		printf("\r");
<STRING>(\\")               		printf("\"");
<STRING>(\\0)               		printf("\0");
<STRING>(\\x[2-7][0-9a-fA-F])    	printf("%s", yytext);
<STRING>(\\x[8-9][0-9a-fA-F])       { /* ERROR */; exit(0); }
<STRING>(\\) 		        		{ /* ERROR */; exit(0); }
<STRING>(\n) 		        		{ printf("Error unclosed string\n"); exit(0); }
<STRING>(\r) 		        		{ printf("Error unclosed string\n"); exit(0); }
<STRING>"            				BEGIN(INITIAL);
<STRING>.                           { printf("Error undefined escape sequence %s\n", (yytext + 1)); exit(0); }

.                                   { /* ERROR */; exit(0); }

%%

void printString(const char* toPrint)
{
    if(NULL == toPrint)
    {
        printf("%d ", yylineno);
        printf("%s ", tokenName[STRING - 1]);
    }
    else
    {
        printf("%s\n", toPrint);
    }
}

void printRecognisedToken(tokentype whichToken)
{
    printf("%d ", yylineno);
    printf("%s ", tokenName[whichToken - 1]);

    switch(whichToken)
    {
    case STRING:
        exit(0); //Should be unreachable code
        break;
    case COMMENT:
        printf("//\n", yytext);
        break;
    default:
        printf("%s\n", yytext);
        breaK;
    }
}