#include<stdio.h>
#include<time.h>
#include<stdlib.h>
#include<string.h>
void game1();
void game2();
void display(char c[],char h[],int b);
void hangman(char c[],int z);
void current(char c[],char h[],int b);
int main()
{
     int a=0;
     while(a<=2){
     printf("\nSelect your choice of game\n");

     printf("\n1)ROCK PAPER AND SCISSOR\n2)HANGMAN\n3)EXIT\n");
     scanf("%d",&a);
     switch(a)
     {
          case 1:
         { printf("\n   Hmm interesting choice\n");
           printf("\n-- 'o' WELCOME TO ROCK PAPER SCISSORS --");
           game1();
            break;
         }
          case 2:
         { printf("You might be quite the guesser to choose HANGMAN!\n");
            printf("\n-- '3' WELCOME TO HANGMAN --\n");
            game2();
            break;
         }
         default:
             {
                 printf("\nThank you for playing!\n\nLobby Closed! \\'-'/\n");
                 exit(0);
             }
     }
     }
     return 0;
}
void game1()
{
   int rounds;
   int play;
   printf("\n\nEnter the number of rounds to play! ");
   scanf("%d",&rounds);
   int player_score=0,comp_score=0;
   srand(time(NULL));
   for(int i=1;i<=rounds;i++)
   { int player_choice,comp_choice;
    printf("\novo~ ROUND %d BEGINS!\n",i);
    printf("Enter your choice(0 for Rock,1 for Paper,2 for Scissors): ");
    scanf("%d",&player_choice);
    while(player_choice>2)
    {
      printf("That is invalid, enter again:");
      scanf("%d",&player_choice);
    }
    comp_choice=rand()%3;
    printf("The computer choses:%d\n",comp_choice);
    if(player_choice==comp_choice)
    {
        printf("\nWelll~ its a tie!\n");
    }
    else if((player_choice==0&&comp_choice==2)||(player_choice==1&&comp_choice==0)||(player_choice==2&&comp_choice==1))
    {
        printf("You win this round!\n");
        player_score++;
    }
    else
    {
        printf("UH OH the computer won this round ;-;\n");
        comp_score++;
    }
   }
   printf("\nWHO WON???\n");
   printf("Your Score: %d\nComputer Score:%d\n",player_score,comp_score);
   if(player_score>comp_score)
   {
       printf("\nYOU WOOOOOONNNNN!\n");
   }
   else if(player_score==comp_score)
   {
       printf("\nWell it looks like a tie!\n");
   }
   else
   {
       printf("\nWomp Womp you lost\n");
   }


}

void game2()
{
    srand(time(NULL));
    const char *words[3] = {"strawberry", "watermelon", "cherry"};
    const char *hints[3] = {"A red fruit often with a sweet or tart taste","Green on outside, Pink on inside","A Red fruit with large seed inside"};
    int randomIndex = rand()%3;
    const char *randomWord = words[randomIndex];
    const char *hint = hints[randomIndex];
    printf("\nHINT:%s\n",hint);
    int b=strlen(randomWord);
    char c[100],h[100];
    strcpy(c,randomWord);
    for(int i=0;i<b;i++)
    {
        h[i]='_';
    }
    h[b]='\0';
    int z=0,x=0;
    char a;
    while(z<=5)
    {
     printf("\nEnter your guess! ");
     scanf(" %c",&a);
     int p=0;
     for(int i=0;i<b;i++)
     {
         if(c[i]==a)
         {
                h[i]=a;
                p++;
         }
     }
     if(p!=0)
     {
         hangman(c,z);
         display(c,h,b);
         x++;
     }
     else
     {
        printf("The letter does not occur in the word\n");
        hangman(c,z);
        current(c,h,b);
        z++;
     }
     int d=0;
     for(int i=0;i<b;i++)
     {
        if(c[i]==h[i])
        d++;
     }
     if(d==b)
     {
            printf("\nCongratulations ! You have guessed the word : %s",c);
            break;
     }
    }
    printf("\nYou guessed:%d right letters and %d wrong letters\n",x,z);
}

void hangman(char c[],int z)
{
 const char *hm[]=
 {
     "                                __________",
     "                             |     |",
     "                             |     O",
     "                             |    /|\\",
     "                             |    / \\",
     "                             |        "
 };
 if(z>5)
 {   printf("Sorry, you've run out of tries. The word was: %s\n",c);
     exit(1);
 }
 else
 {
     for (int i=0;i<=z;i++)
     {
        printf("%s\n", hm[i]);
     }
}
 }
 void current(char c[],char h[],int b)
{
   for(int j=0;j<b;j++)
     {
     if(c[j]==' ')
     {
        printf(" ");
     }
 else if(h[j]==c[j])
     {
        printf("%c",h[j]);
     }
 else
     {
        printf("_");
     }
 }
    printf("\n");
}

 void display(char c[],char h[],int b)
 {
    printf("Good Guess!\n");
 for(int j=0;j<b;j++)
     {
     if(c[j]==' ')
     {
        printf(" ");
     }
 else if (h[j] == c[j])
     {
        printf("%c", h[j]);
     }
 else
     {
        printf("_");
     }
 }
    printf("\n");
}

