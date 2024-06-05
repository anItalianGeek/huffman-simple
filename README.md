# Huffman Encoding and Decoding Program in Assembly

This Assembly code represents a program that implements the encoding and decoding of a message using the Huffman algorithm. The Huffman algorithm is used for data compression, allowing symbols to be represented more efficiently depending on their frequency of occurrence.
I have built this in june 2023, the idea came to me after an assignment i had to do, at the time I used C# (you may find the .cs file in this repo) but I tought it was worth giving it a try in assembly, so here it is.

## Program Structure

The program is structured into different sections, each with a specific purpose:

### Initialization Phase

Data and variables necessary for the program's operation are declared. These are mainly arrays containing letters, their frequencies, and support variables.

### Grouping Phase

This section performs the first step of the Huffman algorithm. It takes the elements with the lowest frequencies, combines them, and updates the frequencies, thus creating a tree structure.

### Vector Correction and Tree Structure Creation Phase

In this phase, the program verifies and corrects the structure to ensure that the groups of letters are correctly ordered and ready for the assignment of binary values.

### Binary Value Assignment Phase

Here, each letter is assigned a binary sequence based on the Huffman tree structure.

### User Interaction Phase

The program asks the user whether they want to encode or decode a message. Based on the choice, it proceeds with the respective operation.

### Encoding Process

The user enters a string that is encoded using the generated binary code table.

### Decoding Process

The user enters a string of binary codes that is decoded to retrieve the original message using the Huffman tree structure.

### Program Exit

The program terminates once encoding or decoding is complete.

## Usage

To use this program, follow these steps:
1. Compile the Assembly code using an appropriate assembler.
2. Run the compiled program.
3. Follow the on-screen prompts to encode or decode a message.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
