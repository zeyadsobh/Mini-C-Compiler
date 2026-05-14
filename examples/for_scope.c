/* Each for-loop declares its own 'i'; with the scope fix, this must compile. */
int main()
{
    int total = 0;

    for (int i = 0; i < 10; i = i + 1)
    {
        total = total + i;
    }

    for (int i = 0; i < 5; i = i + 1)
    {
        total = total + i;
    }

    return total;
}
