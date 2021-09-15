---
{
  "type": "blog",
  "author": "Pancakem",
  "title": "Writing a Raspberry Pi GPIO driver",
  "description": "A baremetal rust gpio driver",
  "image": "images/article-covers/hello.jpg",
  "published": "2020-07-09",
}
---


# Writing a Raspberry Pi GPIO driver

This article is about understanding the Raspberry Pi 3 GPIO hardware interface and writing a driver for it in Rust. You will look at the GPIO pins and registers, and see code samples in Rust that will give you an idea of how to write the driver for your system.

**Introduction**

**Definitions**

A device driver is a program that operates or controls a device connected to your computer. The driver provides a software interface for the host operating system or other programs to get access to the hardware without having to know exact information required to operate that device.

From that definition you realize as the driver author you are required to understand the hardware you are about to control. What's GPIO?

A general-purpose input/output (GPIO) is a pin that handles both incoming and outgoing digital signals. The "general purpose" means that it is not committed to a particular function, each pin can be set to function as either input or output. A GPIO port is a collection of GPIO pins that can be configured to act as either input or ouput. The GPIO peripheral is configured and controlled using a set of registers.

A register is a fast small memory accessible to and located in the processor. They are used to store calculation results, CPU execution states, and other information crucial to program execution.

**Introduction to the Raspberry Pi 3B+**

Now you get a look at the hardware, the Raspberry Pi 3B+.

The Pi 3B+ features a 1.4GHz 64-bit quad-core ARM Cortex-A53 CPU and it uses the BCM2837B0 Broadcom chip, which is also used in the Pi 3A. The chip underlying architecture is identical to the BCM2837A0 chip that is used in Pi 3.

On the Raspberry Pi, there are 54 GPIO lines, split into 2 banks (study image below), only a few are brought out on the board; the rest are used in making the processor act like an actual computer, having things like LEDs, USB connector and the SD card.

![Writing%20a%20Raspberry%20Pi%20GPIO%20driver%20e78c71ab71594f3da7d6f46b6fa8656d/gpio_diagram.png](Writing%20a%20Raspberry%20Pi%20GPIO%20driver%20e78c71ab71594f3da7d6f46b6fa8656d/gpio_diagram.png)

All GPIO pins at least have two functions. GPIO pins can be configured as either general-purpose input or general-purpose output, or as one of up to six special alternate settings, the functions of which are pin-dependent. By alternate setting, I mean different functions apart from the general-purpose input/output. GPIO can be used to provide alternative functions like Serial Peripheral Interface(SPI), PWM and I2C.

The Raspberry Pi, like most micro-controllers, uses memory-mapped I/O interfaces (registers) to control hardware peripherals. Each register has a number of fields: each a set of one or more bits to be read to or written to. Each field will indicate a logical ability in the peripheral. Your driver code will use these memory-mapped registers to interact with the peripheral and provide an interface to the rest of the system.

This article uses Rust, a language designed to map directly to hardware, giving you control over the speed and memory usage of your programs. Rust is unique in that it enforces safety without runtime overhead, most importantly, without the overhead of garbage collection. If you are not acquainted check out the Rust [website](https://www.rust-lang.org/) first, get some basic knowledge in the language.

You now have a basic idea of what should be going on. Next you take a dive with some Rust code to guide you.

**Defining the GPIO registers.**

In the code below two GPIO registers are defined. A macro `register_bitfields` from the [register](https://docs.rs/register/0.5.1/register/index.html) crate is used. The macro help us define a register and its fields. It defines each register's fields with their offsets within the register and their lengths, both in bits. If the values for the fields have names, those are also included. Read through the code comments to get a better idea.

```rust
register_bitfields! {
   u32, // this defines the register width for the bitfields

	 // Here we specify the register name
   /// GPIO Function Select 1
   GPFSEL1 [
				// NUMBITS specify the length of the field
				// OFFSET specifies the bit location within the register
        /// Pin 15
        FSEL15 OFFSET(15) NUMBITS(3) [
						// Inside here are the specified states it can be in
            Input = 0b000,
            Output = 0b001,
            AltFunc0 = 0b100  // PL011 UART RX

        ],

        /// Pin 14
        FSEL14 OFFSET(12) NUMBITS(3) [
            Input = 0b000,
            Output = 0b001,
            AltFunc0 = 0b100  // PL011 UART TX
        ]
    ],

    /// GPIO Pull-up/down Clock Register 0
    GPPUDCLK0 [
        /// Pin 15
        PUDCLK15 OFFSET(15) NUMBITS(1) [
            NoEffect = 0,
            AssertClock = 1
        ],

        /// Pin 14
        PUDCLK14 OFFSET(14) NUMBITS(1) [
            NoEffect = 0,
            AssertClock = 1
        ]
    ]
}
```

More information on the registers defined above:

- GPIO Function Select (`GPFSEL1`) register is used to define the operation of the general-purpose I/O pins. Inside the register, the `FSEL15` **is a read and write field. It ranges from bit 15 to 17 that's why you see `NUMBITS(3)`. The field determines the functionality of the 15th pin. It can be set to either input or output or an alternative function. The same is done for the 14th pin using field `FSEL14`*.*
- GPIO Pull-up/down Clock (`GPPUDCLK0`) register. It controls the actuation of the internal pull-downs on the respective (in the fields) GPIO pins. Remember pull-up and pull-down from your electronics class? No? Quick [reminder](https://electronics.stackexchange.com/questions/7423/what-is-a-pull-up-and-pull-down)!

Next we define the register structs using macro `register_structs`. The macro expects the offset for each register, a field name and a type. The registers must be declared in increasing order of the offsets and contiguously. Gaps when defining the registers must be explicitly annotated with an offset and gap identifier (by convention using a field named `_reservedN`), but without a type. The macro will then automatically take care of calculating the gap size and inserting a suitable filler struct. The end of the struct is marked with its size and the `@END` keyword, effectively pointing to the offset immediately past the list of registers.

```rust
register_structs! {
    #[allow(non_snake_case)]
    RegisterBlock {
        (0x00 => GPFSEL0: ReadWrite<u32>),
        (0x04 => GPFSEL1: ReadWrite<u32, GPFSEL1::Register>),
        (0x08 => GPFSEL2: ReadWrite<u32>),
        (0x0C => GPFSEL3: ReadWrite<u32>),
        (0x10 => GPFSEL4: ReadWrite<u32>),
        (0x14 => GPFSEL5: ReadWrite<u32>),
        (0x18 => _reserved1),
        (0x94 => GPPUD: ReadWrite<u32>),
        (0x98 => GPPUDCLK0: ReadWrite<u32, GPPUDCLK0::Register>),
        (0x9C => GPPUDCLK1: ReadWrite<u32>),
        (0xA0 => @END),
    }
}
```

The macro generates  C-style struct that defines the registers. The crate's register interface offers three types: `ReadOnly`, `WriteOnly`, and `ReadWrite`. For more information and the methods look at the [docs](https://docs.rs/register/0.5.1/register/mmio/index.html). This interface helps the Rust compiler catch some common types of bugs via type checking.

The generated struct should look like this

```rust
#[repr(C)] // this simply tells the Rust compiler to arrange the struct fields
// like C does. The ordering, size and alignment in the C way.
// this is important because Rust usually re-orders struct fields while C does not
// and you can imagine the debugging trouble you would be in
// if the fields were even slightly
struct RegisterBlock{
		GPFSEL0: ReadWrite<u32>,
		GPFSEL1: ReadWrite<u32, GPFSEL1::Register>,
    GPFSEL2: ReadWrite<u32>,
    GPFSEL3: ReadWrite<u32>,
    GPFSEL4: ReadWrite<u32>,
    GPFSEL5: ReadWrite<u32>,
    _reserved1,
    GPPUD: ReadWrite<u32>,
    GPPUDCLK0: ReadWrite<u32, GPPUDCLK0::Register>,
    GPPUDCLK1: ReadWrite<u32>,
}
```

Great you have the registers needed to control the device.

```rust
// A representation of the GPIO hardware
pub struct GPIO {
	base_addr: usize,
}

// Implementing the trait `core::ops::Deref` for GPIO
// allows you to derefence the immutable non-pointer type GPIO
impl core::ops::Deref for GPIO {
	type  Target = RegisterBlock;

	fn deref(&self) -> &Self::Target {
			unsafe { &*self.ptr() }
	}
}

impl GPIO {
	pub const fn new(base_addr: usize) -> Self {
			Self { base_addr }
	}

	// Return a pointer to the associated memory-mapped IO register block
	fn ptr(&self) -> *const RegisterBlock {
			self.base_addr as * const _
	}
}
```

You will need to include a synchronization primitive to your code. This is to make sure that only a piece of code or software has ownership or reference to the same hardware (treat your hardware like data) at time.

**References**

[BCM2837B0](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2837b0/README.md)

[Universal asynchronous receiver-transmitter](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter)
