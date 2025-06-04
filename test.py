from micropython import const

def main():
    # This is a simple test script for MicroPyDS (MicroPython on Nintendo DS).
    # It will print "Hello, DS World!" to the console.
    print("Hello, DS World!")

    # Loop forever (the NDS expects the main thread to keep running)
    while True:
        pass

if __name__ == "__main__":
    main()
