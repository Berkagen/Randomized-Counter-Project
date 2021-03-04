# Randomized-Counter-Project
The aim of this project is to implement a randomized counter to 4-digit SSD in Assembly.  It is aimed to make an algorithm that will display the ID (last three digits.) when the code is not counting. When an external button is pressed, it will generate a 3-digit random number, and start counting down to 0. When the counter reaches 0, the number 000 should be displayed for a second, then the code will go back to idle state ,which is display the ID, waiting for the next button press. Pressing the button while counting down will pause counting, and pressing again will resume counting.

### Schematic Diagram

![resim](https://user-images.githubusercontent.com/44584158/110010143-0a058180-7d2f-11eb-845b-b24644b9a1e5.png)

### Block Diagram

![resim](https://user-images.githubusercontent.com/44584158/110010253-24d7f600-7d2f-11eb-9d74-d5f47dde0333.png)

### Flow Chart

![resim](https://user-images.githubusercontent.com/44584158/110010296-2f928b00-7d2f-11eb-97b7-78e4e38829c9.png)

### Parts List (w/prices)

- 4x 1k resistor 0,02 TL
- 4 Digit SSD (Seven Segment Display) 7,34 TL
- M-M Jumpers 3,11 TL
- 1x Push button: 0,31 TL
- 1x Blue Led: 0,16 TL
-STM32G031K8: 120 TL
Total: 130,94 TL

### Project Setup

![resim](https://user-images.githubusercontent.com/44584158/110010362-4802a580-7d2f-11eb-8bfe-be8b510d6792.png)

### Detailed Task List

Task 1) Turn on the SSD’s first digit.
Task 2) Show a number on the first digit.
Task 3) Count 1 to 9 and show on the first digit.
Task 4) Show the ID number on the SSD.
Task 5) When the button is pressed, change the number and wait one second, then return back to idle state.
Task 6) When the button is pressed, generate a random number and show it on the SSD.
Task 7) break the randomly generated number into its digits, and save to registers.
Task 8) Count back and reset the number.
Task 9) Wait one second and return back to idle state.
Task 10) When the button is pressed, stop the count back process.
Task 11) When the button is pressed, continue the count back process.

### Methodology For Any Numerical Work (Counting_Back Function)

Counting_Back function is a function that counts back the number to 0 when the button is pressed. To explain its methodology, the Counting_Back function checks the registers r0, r1 and r2 respectively, holding the numbers to be displayed in the Display2, Display3 and Display4 functions. Since R2 represents the units digit, it should work faster than the other digits. For this, an algorithm as follows has been applied. When R2 is equal to zero, it will go to R1 (the tens digit), R1 will decrease one and check itself if it is equal to zero, if it is equal to zero it will go to R0 (Hundreds digit) and decrease it by one. When a certain amount of delay is given to R2, the function will successfully perform the countdown.

### Annoyance Parts of the Code

Challenges That’s Been Solved:
1) Keeping a 3-digit number on the screen.
2) Breaking a number into its digits
3) Inability to continuously update the display function while doing the countdown.

How Was This Challenges Solved:
1) A display function has been created. This function continuously activated display2, display3 and display4, respectively, depending on the number of registers r0, r1 and r2. Thanks to this endless loop, a 3-digit number could be kept on the screen.
2) For this, Divide functions were created and three registers were assigned to zero. Divide2 function took the randomly generated number and put the number in hundreds of digits into register r0. Divide3 function put the number in the tens digit to the register r1. Finally, the Divide4 function took the number in the units digit and put it into the r2 register.
3) To solve this, a certain number was given to a register and a loop with display functions was created. When count_back_r2 function worked, it went to that loop and returned the register value and this was repeated continuously.

Unsolved Difficulites:
1) Pressing the button sometimes does not stop the countdown process.
2) In some occasions, when the button is pressed again after stopping the count, it continues for a moment and then stops again.
What is thought to be the root of the problem?
1) The code for the button is pressed when the process can happen very quickly in trying to perform two functions.
2) Likewise, The code for the button is pressed when the process can happen very quickly in trying to perform two functions.

### Conclusion and Comments
As a result, in this project, the controls of stm32g031k8's ODR, IDR, MODER, PUPDR instructions, debugging the code via STM32CubeIDE program using buttons such as step over, step into, resume and assigning break points, while in Debug mode, seeing the current value of registers in the registers tab, checking the values of STM32's instructions from SFR's section has been learned in detail. At the same time, the experience of physically operating 4 digit ssd with stm32g031k8 has been gained. Also, separating the project into tasks helped the algorithm to be developed more accurate. As a comment, some problems were encountered while doing the project. The first annoyance was Pressing the button sometimes does not stop the countdown process. This problem could not be solved, but it is thought that the code for the button is pressed when the process can happen very quickly in trying to perform two functions. The second problem was that when the button is pressed again after stopping the count, it continues for a moment and then stops again in some occasions. This problem could not be solved either, and it is thought that the same thing is the root of this problem. In addition, This project was very helpful in building algorithms in assembly language and understanding the relationship of the microprocessor to other peripherals on the breadboard.

