---
layout: post
title: "Understanding Python: Variables, Scope and Namespaces"
date: 2019-06-09 10:32:42 +0300
categories: python
---

# Introduction
Python is a friendly and powerful general-purpose language. If you
want more performance to your solution Python may not be the way to
go, there are better solutions out there like Rust, C and C++. This
does not mean you can not get better performance from your
python. There are ways you can use to get good performance and in
order to use them to squeeze performance out of your Python, you have
to understand how Python does things. So unless you have real
performance problems, you should write code for clarity, not for
performance gains.

This article is aimed at introducing the reader to
how Python works and so that ultimately they can write better Pythonic
code. The article considers the CPython implementation of Python.

# Variables, scope and namespaces.
Python does not have variables in the same sense as other languages
like C and Go. In Go for example, a variable may be declared as follows.

{% highlight go %}
	var x int = 20
{% endhighlight %}

This will allocated some memory, most probably on the stack, and the
variable x will be associated with that memory. And when you change
the value of the variable `x`, the memory associated is modified.

Python does things differently in a very clever way.

Now let us better understand variables and assignment in Python.
A `name` is a Python identifier used to point to values, functions,
modules or any other object.
In Python a variable is analogous to a name though not exactly. A name can
be, more precisely, thought of as a reference to a value.

Study the code snippet below,

```python
>>> a = 5
```
`a` is a name that references the int object, `5`. The process of assigning the
reference `5` to `a` is called binding. A binding associates a name to
an object in the innermost scope of the currently
executing part of the program. Bindings occur during a number of
instances,

* when you create a 'variable' like the example above
* when you pass a variable or a value to a function.

Every time binding happens a reference count is added. A reference count is stored in
every object in Python, this helps in garbage collection. When the
reference count of an object hits zero, it is garbage collected.

```python
>>> b = 8
>>> a = b
>>> id(b)
9079232
>>> id(a)
9079232
>>> del a # delete the reference
>>> a = 8 # assign a to 8  and check the id
>>> id(a)
9079232
```
In the above example, Python creates an integer
object, 8, in memory then the name `b` is bound to the object.
When `b` is assigned to `a`, name `a` will point to the same object `b`
references. Kind of like this,
```C
int *b = &a
```
in C.

In C, however, `a = b` will take value at the memory location of a and
copy it to another memory slot for b. Python is smart, if an object
exists anywhere in memory it reuses the object. This explains why in
the above python snippet, a and b have the same `id`. The `id(object)` function
takes an object then returns a unique constant integer that is the
memory location of the object, at least in CPython. This should lead
us to mention the `is` keyword which tests if two names reference the
same object, that is if they have the same 'identity' returned by id(object).

```python
>>> a = [3,4,5]
>>> b = a
>>> a == b # compares the object
True
>>> a is b # compares the ids
True
>>> b = a[:] # get a different object with the same value
>>> b == a # same value
True
>>> b is a # different ids
False
```
It could get dangerous, if you have two names referencing the same
object at the beginning but later want to mutate them differently and independently. Look at this:

```python
>>> a = [3,6,9]
>>> b = a
>>> a[2] = 0 # mutate a
>>> b # the changes in a reflect in b,`names refer the same object`
[3, 6, 0]
```
Re-assigning happens independently of each other, do not worry.

```python
>>> a = 5
>>> b = a
>>> b = 2
>>> a
5
```
If you want to mess around with one variable while leaving the other untouched. You could do this:

```python
>>> a = [3,6,9]
>>> b = a
>>> b = [item for item in b]
>>> id(a)
139948589561864
>>> id(b)
139948590367176
```

Think that is tiresome? This is easier,

```python
>>> a = [3,6,9]
>>> b = a[:]
>>> id(a)
140594772693512
>>> id(b)
140594771888200
```
But there is also the copy module way,

```python
>>> import copy
>>> a = [3,6,9]
>>> b = copy.copy(a) # this is a shallow copy
>>> id(a)
139948589561608
>>> id(b)
139948572147144
```
A shallow copy copies, to a certain extent, the references to an object. If you want to make sure everything is copied you can use the deepcopy function. Though when you perform a copy of a complex data structure, its values will still be references of the same object. For example, making a copy of a list

```python
>>> import copy
>>> a = [3,6,9]
>>> b = copy.copy(a) # this is a shallow copy
>>> id(a)
139948589561608
>>> id(b)
139948572147144
>>> id(b[1])
9079168
>>> id(a[1])
9079168
```
Hey, we are not done. We have looked at names as references so far. But references can be more than just names, check this out.

```python
>>> a = 7
>>> b = [7, 8, 9]
>>> id(a)
9079200
>>> id(b[0])
9079200
```
Complex data structures hold objects and each of those fields ( here a field could be a index in a list, an object attribute and so on ) is a reference. Let's do another example with a class,

```python
>>> class Test():
…     n = 0
…     def __init__(self, n):
…         self.n = n
…
>>> a = 7
>>> t = Test(7)
>>> id(a)
9079200
>>> id(t.n)
9079200
```
Anything that can appear on the left-hand side of an assignment statement is a reference. This is a nice feature that makes Python faster, copies would slow the language so much.
It goes onto function arguments, they also are like the normal assignments:

```python
>>> def modd(lis, num):
…      for i in range(num):
…         lis.append(i)
…
>>> x = [3,4,5]
>>> modd(x, 5)
>>> x
[3, 4, 5, 0, 1, 2, 3, 4]
```
Function arguments are also assigned and you know what that means. `lis` and `num` are local variables to the function and they are bound, binding occurs, to become references to the objects that will be passed to the argument when called. When the function returns the lis and num references are destroyed but the change will have occurred on the object they referenced. Although this behavior might be surprising, it's essential. Without it, we couldn't write methods that modify objects. Look at this

```python
>>> def unmodd(lis, val):
…     for i in range(num):
…         lis = lis + [i]
…
>>> x = [0,1,2]
>>> unmodd(x, 2)
>>> x
[0, 1, 2]
```
This does not work. A new assignment occurs because on the right hand-side a new list is created, a new object, so the local reference lis will reference the new list object. If you want to keep the change you only have to add a return statement and assign to the name.

```python
>>> def unmodd(lis, val):
...     for i in range(val):
...             lis = lis + [i]
...     return lis
...
>>> x = [0, 1, 2]
>>> p = unmodd(x, 3)
>>> p
[0, 1, 2, 0, 1, 2]
```

## Namespace
A namespace is a context where a given set of names are bound to objects. They are, basically, where names live. Namespaces are collections of (name, object reference) pairs (implemented using dictionaries). The Python interpreter has access to multiple namespaces including the main ones, the built-ins namespace, the global namespace and the local namespace. The namespaces are created at different times and have different lifetimes. For example, the local namespace is created at the invocation of a function and exists until the function returns to its caller or exits. The global namespace is created at the start of execution of a module while the built-in namespace is created when the interpreter starts.

In the CPython implementation, local variable store is fast. What happens is when a function is invoked, all local variables are stored in a fixed size array and the variable names are assigned to the indexes. Thus retrieving a local variable is a simple lookup into the array. A global lookup, is not inside a dictionary which involves hashes, hence not as fast as local variable lookup. However, the global lookup has been optimized and is not so slow. Object attribute lookup is very slow.
To see whats available in the built-in namespace, enter the REPL and run __builtins__.__dict___ .


## Scope
A scope is an area of a program where a set of name bindings are
visible and directly accessible unambiguously and without a dot
notation. The following scopes can be available:

1. Inner most scope with local names
2. The scope of enclosing functions if any (this is applicable for nested functions)
3. The current module's globals scope
4. The scope containing the builtin namespace.

When a name is used in python, the interpreter searches the namespaces
of the scopes in ascending order as listed above and if the name is not found in any of the namespaces, an exception is raised.


A code block is a unit of the program code that is executed as an independent unit. In Python, the for, while or if are not code blocks. Modules, classes and functions are the code blocks. Code blocks have namespaces associated with them like we mention earlier that the global namespace is tied to a module.

#### A little better code take away
Now that we have learnt how Python handles 'variables', we can make a
few statements on writing more Pythonic code that achieves speed.
From namespaces we have learnt that, the namespace lookup is upward. This means that the interpreter accesses local variables much more efficiently than global variables. Using local variables whenever possible and especially inside for loops is a good optimization practice. Let's see a code snippet

```python
def list_from_sentence(sentence):
    newlist = []
    for word in sentence:
        newlist.append(str.upper(word))
    return newlist
```
In the above example, the interpreter would have to lookup the reference for newlist.append and str.upper for every iteration, that is an overhead (remember we said object attribute lookup is slow). This overhead can be avoided if we change the function implementation to the code below

```python
def list_from_sentence1(sentence):
    upper = str.upper
    newlist = []
    append = newlist.append
    for word in sentence:
        append(upper(word))
    return newlist
```
Storing the str.upper and newlist.append references in local
variables, which are easily accessed. Thus for every iteration we do
not incur the unnecessary lookup. Thus making the second
implementation potentially faster but not necessarily.

## Conclusion

We can summarize this as follows:
* An assignment statement modifies a namespace but not an object. Assigning the variable x = 5 you are adding the name x to your local namespace.
* The is operator compares the unique object id, it differs from the == operator that compares the object value.
* Python avoids copies on assignments to save memory which would otherwise make it really slow.


I believe as one explore the internals of a particular tool or
language one gets better at using it.
