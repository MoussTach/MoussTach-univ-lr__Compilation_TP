using System;

public class ReadWrite {
    static public void Main() {
        int a = int.Parse(Console.ReadLine());
        int b = int.Parse(Console.ReadLine());

        while (!(a == b)) {
            while (a > b) {
                if (a > b  || a < b) {
                    Console.WriteLine(a);
                    Console.WriteLine(a);
                } else if (a < b) {
                    Console.WriteLine(b);
                    Console.WriteLine(b);
                } else {
                    Console.WriteLine(a + b);
                    Console.WriteLine(a + b);
                }
                b = b + 1;
                break;
            }
            a = a + 1;
            continue;
        }

        Console.WriteLine(b);
        Console.WriteLine(b);
    }
}