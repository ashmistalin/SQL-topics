#include <stdio.h>
#include <string.h>

void print(const char* str, int start, int end) {
    for (int i = start; i <= end;i++)
        printf("%c", str[i]);
}

void longestPal(const char* str) {
    int length = strlen(str);

    int maxLength = 1, start = 0;

    for (int i = 0; i < length; i++) {
        for (int j = i; j < length; j++) {
            int flag = 1;

            for (int k = 0; k < (j - i + 1) / 2; k++)
                if (str[i + k] != str[j - k])
                    flag = 0;

            if (flag && (j - i + 1) > maxLength) {
                start = i;
                maxLength = j - i + 1;
            }
        }
    }

    printf("Longest palindrome substring is: ");
    print(str, start, start + maxLength - 1);
    printf("\n");
}

int main() {
    char str[1000];
    printf("Enter a string: ");
    scanf("%s", str);
    longestPal(str);
    return 0;
}
