---
layout: post
title: "Here is a problem"
description: "A small possibly non halting problem ..."
date: 2021-08-23 11:13:54 +0300
---

# Introduction

Say we have a program that requires the user to enter a 20 character long password, S.
In order to validate the password, the program casts every 4 characters into a 32 bit integer
and the 5 integers are summed up producing a hashcode X.

Suppose we lost our password, and wrote a program to try and find a string S that will produce the
hashcode X. Is it possible to write a halting program to give us access to our program?

I am not yet sure about the answer to that question. I have done some investigating and experimentation.
Let me share my process and findings,

## Approach one

My first approach was to write a python script that generates a random 20-byte ascii string
then tests if the string can produce our desired hashcode.


### Step 1: Generate string

```python
import string
import random

def make_20_byte_str():
	made_str = ''.join(random.SystemRandom().choice(string.punctuation
		+ string.ascii_uppercase + string.ascii_lowercase +
		string.digits) for _ in range(21))
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
Well, then I thought of moving to a different, possibly faster, approach.

## Approach two

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
	# there was a remainder,
	#ets handle the remainder and set the rng value to 4
	rng = 4
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


## Conclusion

~~I feel I have not broken deep enough into this problem. Anything new, I'll add onto here.
If you think there's a better and conclusive way to approach the problem please reach out
at pancakesdeath at protonmail.com~~

The problem I am looking at here is indeed solvable in theory, given sufficient computational power and time. However, the practical feasibility of solving it depends on the scale of the computation required and the constraints of the problem.

The problem has a finite search space given the example of a 20-character password we used above. That password has a possible 94 character composition, the total number of combinations `94^20` which is approximately `7.9 x 10^39`. While this is a large number it still is finite.

A brute-force approach like I have tried above *will* eventually find the correct password, given enough time and computational resources. With a finite search space, a program that is halting can eventually reach a correct password.

Another thing to look at is the possibility of collisions. The hashcode computation mechanism is simple and deterministic but there is high chances for collisions where multiple passwords produce the same hashcode. Hence the program will halt at finding **a valid** password that is not necessarily the original password.

The brute-force approach I have followed here is impractical (I scream at the 16 hours of senseless computation). The problem is tractable and practical with a parallized implementation where we can throw the problem at GPUs or use [rainbow tables](https://en.wikipedia.org/wiki/Rainbow_table).
