using System;

namespace codice_di_huffman
{
    internal class Program
    {
        static void Main(string[] args)
        {
            string[] letters = { "F", "B", "C", "R", "A", "E" }; // Array containing the source alphabet
            int[] frequencies = { 1, 9, 17, 17, 19, 37 }; // Array containing the frequencies

            // initial sorting (if necessary)
            bool isToReorderImmediately = false;

            for (int i = 1; i < 6 && !isToReorderImmediately; i++) // check necessity
                if (frequencies[i - 1] < frequencies[i])
                    isToReorderImmediately = true;

            for (int i = 0; i < 6 - 1 && isToReorderImmediately; i++) // for loop that reorders the array of frequencies and also strings (selection sort)
            {
                int position_lowest = i;

                for (int x = i + 1; x < 6; x++)
                    if (frequencies[position_lowest] > frequencies[x])
                        position_lowest = x;

                int temp_freq = frequencies[i]; // swap the frequencies
                frequencies[i] = frequencies[position_lowest];
                frequencies[position_lowest] = temp_freq;

                string temp_string = letters[i]; // swap the letters of the source alphabet
                letters[i] = letters[position_lowest];
                letters[position_lowest] = temp_string;
            }

            // grouping
            bool groupingDone = false; // condition to use for the while loop
            int toCombine = 1;
            int toDelete = 0;
            int indexCompositions = 0;

            string[] compositions = {"", "", "", "", "", ""}; // this array will be used for tree creation
            string[] combinations = {"", "", "", "", "", ""}; // create a new support array for grouping
            int[] newfrequencies = new int[6];

            for (int i = 0; i < 6; i++) // copy elements in order into the new array, taking elements from the source alphabet array
            {
                combinations[i] = letters[i];
                newfrequencies[i] = frequencies[i];
            }
            
            while (!groupingDone)
            {
                compositions[indexCompositions] = combinations[toCombine - 1] + " " + combinations[toCombine]; // save the combination made in the compositions array

                combinations[toCombine] = combinations[toCombine - 1] + combinations[toCombine]; // group two elements (here the letters)
                combinations[toDelete] = ""; // clear the content in this position of the array containing the source alphabet

                newfrequencies[toCombine] = newfrequencies[toCombine - 1] + newfrequencies[toCombine]; // group two elements (here the frequencies)
                newfrequencies[toDelete] = 0; // clear the content in this position of the array containing the frequencies

                bool isToReorder = true; // boolean used only for optimization purposes

                for (int i = 0; i < 6 - 1 && isToReorder; i++) // for loop to determine if the frequencies array has been sorted
                    if (newfrequencies[i] > newfrequencies[i + 1])
                        isToReorder = false;

                for (int i = toCombine; i < 6 - 1 && !isToReorder; i++) // selection sort (ONLY IF NECESSARY)
                {
                    int position_lowest = i;

                    for (int x = i + 1; x < 6; x++)
                        if (newfrequencies[position_lowest] > newfrequencies[x])
                            position_lowest = x;

                    int temp_int = newfrequencies[i];
                    newfrequencies[i] = newfrequencies[position_lowest];
                    newfrequencies[position_lowest] = temp_int;

                    string temp_string = combinations[i];
                    combinations[i] = combinations[position_lowest];
                    combinations[position_lowest] = temp_string;
                }

                toCombine++; // increment counters
                toDelete++;
                indexCompositions++;

                if (newfrequencies[6 - 1] == 100) // when the last element of the frequencies array equals 100, grouping is done
                    groupingDone = true;
            }
            
            int[] compositions_vector_size_each = new int[6]; // create a support array to calculate the sizes of individual strings in the compositions array

            Console.WriteLine(compositions[5]);
            for (int i = 0; i < 6; i++)
                compositions_vector_size_each[i] = compositions[i].Length;

            for (int i = 0; i < 6 - 1; i++) // reorder the compositions size array and in parallel the compositions
            {
                int position_lowest = i;
                for (int x = i + 1; x < 6; x++)
                    if (compositions_vector_size_each[position_lowest] < compositions_vector_size_each[x])
                        position_lowest = x;

                int temp_int = compositions_vector_size_each[i];
                compositions_vector_size_each[i] = compositions_vector_size_each[position_lowest];
                compositions_vector_size_each[position_lowest] = temp_int;

                string temp_string = compositions[i];
                compositions[i] = compositions[position_lowest];
                compositions[position_lowest] = temp_string;
            }

            for (int i = 0; i < 6; i++) // for loop that "corrects" the content of the compositions array to ensure meaningful tree generation
            {
                int spaceindex = compositions[i].IndexOf(" "); // find the position of the space

                string check1 = "", check2 = "";
                for (int untilSpace = 0; untilSpace < spaceindex; untilSpace++) // construct the string up to the space
                    check1 += compositions[i][untilSpace];
                for (int afterSpace = spaceindex + 1; afterSpace < compositions[i].Length; afterSpace++) // construct the second string, after the space
                    check2 += compositions[i][afterSpace];

                if (check2.Length > check1.Length) // check if it's necessary to correct the examined array piece
                    compositions[i] = check2 + " " + check1;
            }

            string[,] dictionary = new string[6, 2]; // create the dictionary where the bits of each letter will be saved

            for (int i = 0; i < 6; i++) // copy the letters into the first row of the matrix
                dictionary[i, 0] = letters[i];

            for (int indexDictionary = 0; indexDictionary < 6; indexDictionary++)
            {
                bool isToLookFurther = true; // condition that checks if a letter's branching is finished

                for (int internal_for_counter = 0; isToLookFurther && internal_for_counter < 6; internal_for_counter++)
                {
                    int letterFinder = compositions[internal_for_counter].IndexOf(dictionary[indexDictionary, 0]); // find the position of the letter

                    if (letterFinder != -1)
                    { // condition that checks if the letter is present in this specific block, if missing it continues as another boolean stops everything if the letter's branching is finished
                        int spaceFinder = compositions[internal_for_counter].IndexOf(" "); // find the position of the space

                        if (letterFinder < spaceFinder) // determine which bit to apply
                            dictionary[indexDictionary, 1] += "0"; // "left"
                        else
                            dictionary[indexDictionary, 1] += "1"; // "right"

                        if (compositions[internal_for_counter].Length == 3) // check if this is the last element where the interested letter appears
                            isToLookFurther = false;
                    }
                }
            }

            for (int i = 0; i < 6; i++)
                Console.Write("Letter " + dictionary[i, 0] + " encoded in binary is " + dictionary[i, 1] + "\n");

            Console.WriteLine("\nPress any key to begin encoding and decoding messages...");
            Console.ReadKey();

            // encoding/decoding phase
            Console.WriteLine("\nDo you want to encode or decode a message? (c = encode, d = decode)");
            char choice = Convert.ToChar(Console.ReadLine());

            switch (choice)
            {
                case 'c':
                    string messageToEncode, encodedMessage = "";
                    Console.Write("Input your message: ");
                    messageToEncode = Console.ReadLine(); // read the input message
                    messageToEncode = messageToEncode.ToUpper(); // make the input case insensitive

                    for (int i = 0; i < messageToEncode.Length; i++) // take a character, search for it in the matrix, and when found, build the string concatenating its binary value
                    {
                        string currentChar = Convert.ToString(messageToEncode[i]);
                        int whileCounter = 0;
                        while (dictionary[whileCounter, 0] != currentChar)
                            whileCounter++;

                        encodedMessage += dictionary[whileCounter, 1];
                    }

                    Console.WriteLine("Your encoded message is: " + encodedMessage);
                    break;

                case 'd':
                    string messageToDecode, decodedMessage = "";
                    bool decoding_completed = false; // condition for the next while loop
                    Console.Write("Input your message: ");
                    messageToDecode = Console.ReadLine(); // read the input message

                    while (!decoding_completed)
                    {
                        int char_index = 0; // pointer to point to the various "bits" (characters) of the input coded message
                        bool[] checker = { true, true, true, true, true, true }; // boolean array that helps me understand which character I'm decoding
                        int howManyTrue = checker.Length;
                        while (howManyTrue != 1)
                        {
                            string bitToCheck = Convert.ToString(messageToDecode[char_index]); // save the bit to check in a support variable

                            for (int indexDictionary = 0; indexDictionary < 6; indexDictionary++)
                            {
                                if (checker[indexDictionary])
                                    if (bitToCheck != Convert.ToString(dictionary[indexDictionary, 1][char_index])) // if the bit does not match a bit of the binary version in a letter, immediately negate its index in the boolean array
                                    {
                                        howManyTrue--;
                                        checker[indexDictionary] = false;
                                    }
                            }

                            char_index++; // increment the counter
                        }

                        int characterToWrite = -1;
                        for (int i = 0; i < 6; i++)
                            if (checker[i]){
                                characterToWrite = i;
                                break;
                            }

                        messageToDecode = messageToDecode.Remove(0, char_index); // remove the decoded part of the input string so I can reset the character pointer and avoid going out of range
                        decodedMessage += dictionary[characterToWrite, 0]; // write the found character

                        if (messageToDecode.Length == 0)
                            decoding_completed = true;
                    }
                    Console.WriteLine("Your decoded message is: " + decodedMessage);
                break;
            }
            Console.WriteLine("\n\nPress any key to quit the program..");
            Console.ReadKey();
        }
    }
}