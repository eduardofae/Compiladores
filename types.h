#ifndef _TYPES_H_
#define _TYPES_H_

enum token_types {
    ID,
    LIT
};

enum types {
    BOOL   = 258,
    INT    = 259,
    FLOAT  = 260
};

enum natures {
    VAR,
    FUNC
};

enum types infer_type(enum types type1, enum types type2);

#endif //_TYPES_H_