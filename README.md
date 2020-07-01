# Robot Path Programming With PIC18F45K22
<div style="text-align:center"><img src="https://i.ibb.co/7p2n0FS/image1.png" /></div>

> This is an academic project, which aims to exploit PIC18 microcontroller's capabilities for realtime control operations
---

### Table of Contents

- [Description](#description)
- [Implementation On Proteus](#implementation-on-proteus)
- [Demonstration](#demonstration)
- [Project Files](#project-files)
- [Author Info](#author-info)

---

## Description

The goal is to simulate a program run on a PIC18 microcontroller on **Proteus** software. The program is responsible of interpreting the user's commands and translating them into robot control actions *(represented by motors).*

The user interface is formed by :

- 10 distance unit buttons : digits from **0** to **9**
- 3 directions buttons : **AHEAD**, **LEFT** and **RIGHT**
- 1 execution button : **GO**

After the user must press a certain number of *direction buttons* followed, each, by a maximum of two digits *(among the distance unit buttons)* representing the distance to be execute by that specific action.

---

## Implementation On Proteus

<div style="text-align:center"><img src="https://i.ibb.co/zrVcX1q/image2.png" /></div>

This is how it works :

- The robot is represented by the four motors that we can control throw the mocrocontroller's **PORT A**
- Two signaling LEDs are used for the same purpose as in an ordinary car *(indicate the following action if it's **LEFT** or **RIGHT**)*
- The push-buttons **AHEAD**, **LEFT** and **RIGHT** are serving as interrupting buttons; at each time a button is pressed, a high interruption on **INT1** is caused *(the signal goes by the **OR** logial port)*. At the same time the microcontroller read the pin of the **PORT C** that receives the logical '1' (it corresponds to a pressed button)
- When the digits are pressed, there is an encoder named **U6** which communicates the value to the microcontroller via **PORT C**. In another hand, an interruption will be caused on **INT1**
- At each time the microcontroller detects an interruption, it decodes the instructions and save it into a table in its memory 
- Once the **GO** button is pressed, the microcontroller executes in order all the instructions already entered, thanks to a pointer to the table containing these instructions

---

## Demonstration

### **A video demonstration is available via the following link :**

*(This content is not yet available)*

---

## Project Files

The project contains one single file :

1. [PIC18_Assembly.asm](PIC18_Assembly.asm) : contains the Assembly code that does the whole

---

## Author Info

- Email - oussama.oulkaid@gmail.com
- LinkedIn - [Oussama Oulkaid](https://www.linkedin.com/in/oulkaid)
