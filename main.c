#include <stdio.h>

void my_printf(const char *format, ...);

int main(void)
{
	my_printf("Hello, %s!\n", "world");
	my_printf("Letter: %c\n", 'A');
	my_printf("Big number: %lu\n", 18446744073709551615UL);
	my_printf("Mixed: %s has %lu items, grade %c\n", "cart", 42UL, 'B');
	my_printf("Stack args: %c %c %c %c %c %c %lu\n",
		  'a', 'b', 'c', 'd', 'e', 'f', 7UL);
	return 0;
}
