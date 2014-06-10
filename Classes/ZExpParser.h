#pragma once

#ifndef __ZEXPPARSER__
#define __ZEXPPARSER__

#include <math.h>

#if defined(__MWERKS__)
#define bcopy BlockMoveData
#endif

// for MPW only (need to check for this here really):

#ifndef bcopy
#include	<string.h>
#define bcopy(src, dest, count) memcpy((dest), (src), (count))
#endif

#define	NUMBER		258
#define	FUNCTION	259
#define	VAR			260
#define	NEG			261


// other funcs:

#ifdef __cplusplus
extern "C" {
#endif

// this structure used to form elements of a simple symbol table which can contain literal values or
// pointers to functions that return values

typedef struct symbol
{
	char* 	name;
	int		type;
	union
	{
		double_t	var;
		double_t	(*func)(double_t arg);
	}
	value;
	struct symbol*	next;
}
symbol;

// this structure used for a table of callable math functions

struct init
{
	char 		*fname;
	double_t 	(*fnct)(double_t arg);
};

int 		yyparse(void* param);
void		yyerror(const char* errStr);

#ifdef __cplusplus
}
#endif

#endif