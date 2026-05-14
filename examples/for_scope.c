/* Demonstrates that variables declared in a for-initializer
 * are scoped to the loop and do not leak into the enclosing scope. */
int main()
{
    for (int i = 0; i < 5; i = i + 1)
    {
        int x = i;
    }

    /* i is no longer in scope here; we can reuse the name freely. */
    int i = 42;
    return i;
}
