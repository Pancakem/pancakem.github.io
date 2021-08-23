---
{
  "type": "blog",
  "author": "Pancakem",
  "title": "Here is a problem",
  "description": "A small possibly non halting problem..",
  "published": "2021-08-23",
}
---

## Here is a problem

Say we have a program that requires the user to enter a 20 character long password, S<sub>20</sub>.
In order to validate the password, the program casts every 4 characters into a 32 bit integer
and the 5 integers are summed up producing a hashcode X<sub>h</sub>.

Suppose we lost our password, and wrote a program to try and find a string S<sub>20</sub> that will produce the 
hashcode X<sub>h</sub>. Is it possible to write a halting program to give us access to our program?

I am not yet sure about the answer to that question. I have done some investigating and experimentation. 
Let me share my process and findings,

My first approach was to write a python script that generates a random 20-byte ascii string 
then tests if the string can produce our desired hashcode.


### Step 1: Generate string

```python 
import string
import random

def make_20_byte_str():
	made_str = ''.join(random.SystemRandom().choice(string.punctuation + string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(21))
	return made_str
```

### Step 2: Produce hashcode from string
By dividing the string into 5 parts each 4-bytes long part converted into an integer, we result into 5 integers that we sum up to a hashcode. 

``` python
import struct

def string_bytes_to_int(the_str):
	res = 0
	parts = list(map(''.join, zip(*[iter(the_str)]*4)))
	for part in parts:
		res += struct.unpack("<i", bytes(part, encoding='utf-8'))[0]
	return res
```

### Step 3: Bring everything together

```python

hashcode = 0x19E09CDF

while True:
	target_string = make_20_byte_str()
	res = string_bytes_to_int(target_string) 
	if res == hashcode:
		print(target_string)
		break
```

I ran this implementation for 16 hours without a result. Of course, the problem should terminate at some point, assuming there are few collisions so that 
we cover the expanse of all possible 20-byte strings.
This can be better viewed as a combination problem. 

The general formula for combination is:

```
	n! / k!(n-k)!
```

So we have a set of 94 possible characters, 52 letters (26 of both uppercase and lowercase), 10 digits and 32 punctuation characters. Thus `n = 94`. 
From this set we want to pick any 20 characters and repetition is allowed. Thus `k = 20`
Because of repetition our combination formula becomes:

```
	(n + k - 1)! / k!(n-1)!
```

The result becomes `7,928,015,940,627,369,981,240`. This means our program should generate that number of strings, 7 sextillion strings and test each for the hashcode.

   

Our program should in the end generate a large number of strings to test.

Well, then I thought of moving to a different, possibly faster, approach.
What if we divide up the hashcode into 4 32-bit integers from which we can pick a character of each its 8-bit value.
Sounds exciting right? Well if you think so, I thought so too until I realised later how flawed the approach is.

Let us check it out.

### Step 1: Integer divide the integer by 5, if there is a remainder add it to the results

```python
 
# returns a list of parts
def get_4_byte_ints(hashcode):
	val = hashcode // 5
	part_with_remainder = val + (hashcode % 5)
	
	if part_with_remainder == val:
		return [val]
	
	return [part_with_remainder, val]
```

### Step 2: Convert each 8-bit of the 32 bit integers to a character

```python
	
def convert_4_byte_int_to_str(int_bytes):
        c_str = ''
        for i in int_bytes:
                c_str += ascii(i)
        return c_str

```
### Step 3: Bring it all together

```python
	

int_parts = get_4_byte_ints(hashcode)
rng = 5
val = int_parts[0]
target_strng = ''
if len(int_parts) == 2:
	# there was a remainder
	rnge = 4
	# get the integer bytes, I am on a little endian system
	ibytes = int_parts[0].to_bytes(4, "little")
	target_strng += convert_4_byte_int_to_str(ibytes)
	val = int_parts[1]

# get all parts
for i in range(rng):
	ibytes = val.to_bytes(4, "little")
	target_strng += convert_4_byte_int_to_str(ibytes)

print(target_strng)
```

Have you noticed the problem? A single byte can represent `0-255`, however, the ascii chart has representations of `0-127`.
This means if any byte value of the integer exceeds 127 we cannot get an `ascii` or a `utf-8` value, we run into a `UnicodeError`. This is the end.
You may think of trying to go for `utf-16`, we may get conversions but this will use 16-bits for every character and we will end up with a 
10 character password which is not our desired result.


## Conclusion, for now

I feel I have not broken deep enough into this problem. Anything new, I'll add onto here. 
If you think there's a better and conclusive way to approach the problem please reach out
at pancakesdeath at protonmail.com

