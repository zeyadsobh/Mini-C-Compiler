/* Exercise escape sequences in char literals (no pointers in mini-C). */
int main()
{
    char nl = '\n';
    char tab = '\t';
    char bs = '\\';
    char q = '\'';
    char dq = '\"';
    char nul = '\0';
    char hex = '\x41';     /* 'A' */
    char oct = '\101';     /* 'A' */

    nl = tab;
    tab = bs;
    bs = q;
    q = dq;
    dq = nul;
    nul = hex;
    hex = oct;

    return 0;
}

