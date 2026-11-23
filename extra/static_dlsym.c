/* Static build without a dynamic linker: dlsym() always fails.
 * On 32-bit musl dlsym() is __dlsym_time64, an asm stub that calls
 * __dlsym_redir_time64 through the GOT. In a static MIPS binary that GOT
 * entry stays 0, so the call jumped to address 0 (exteplayer3 187 calls
 * dlsym() at startup to ask libcrypto for its CA paths, tools/ca_bundle.c).
 * build.sh links with --wrap=__dlsym_time64, so calls end here instead. */
#include <stddef.h>

void *__wrap___dlsym_time64(void *restrict handle, const char *restrict name)
{
    (void)handle; (void)name;
    return NULL;
}
