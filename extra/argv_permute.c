/* musl getopt() does not permute argv like glibc: ServiceApp passes the URL
 * first, so every option after it was ignored. Reorder options before the
 * operands, then call the real main(). EP3_OPTSTRING comes from exteplayer.c. */
#include <stdlib.h>
#include <string.h>

int ep3_main(int argc, char *argv[]);

static int takes_arg(char c)
{
    const char *p = strchr(EP3_OPTSTRING, c);
    return c != ':' && p && p[1] == ':';
}

int main(int argc, char *argv[])
{
    char **opts = calloc(argc + 1, sizeof(char *));
    char **ops  = calloc(argc + 1, sizeof(char *));
    int no = 0, nn = 0, i;
    if (!opts || !ops) return ep3_main(argc, argv);

    opts[no++] = argv[0];
    for (i = 1; i < argc; i++) {
        char *a = argv[i];
        if (strcmp(a, "--") == 0) {            /* everything after is an operand */
            for (i++; i < argc; i++) ops[nn++] = argv[i];
            break;
        }
        if (a[0] != '-' || a[1] == '\0') {     /* operand (URL / file / "-") */
            ops[nn++] = a;
            continue;
        }
        opts[no++] = a;
        /* walk option cluster: "-ab", "-x<arg>", "-x" "<arg>" */
        for (const char *c = a + 1; *c; c++) {
            if (takes_arg(*c)) {
                if (c[1] == '\0' && i + 1 < argc) opts[no++] = argv[++i];
                break;
            }
        }
    }
    for (i = 0; i < nn; i++) opts[no++] = ops[i];
    opts[no] = NULL;
    return ep3_main(no, opts);
}
