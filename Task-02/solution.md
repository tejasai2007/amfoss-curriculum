# Sub Task 1
## Assignment 
> First we need string data type to show the name of the product you are having in the cart. Next is number to show the price of the product.we can use operators in middile for the total calculation and others. undefined might be used if any error occurs or to say that the cart is empty. null to give any emptty values.
## Challanges
> Here age =1 and Age =2 since age is not equal to Age it returns false.
### Gotchas
> 1. First gotcha got to know is Nan in not equal to itself if we use typeof command. We must use isNan() function to get the correct answer. 
> 2. The next one is typeof null is object.
> 3. Next is == is not equal to === . == Changes the type if possible to make it equivalent but === checks the literal LHS to RHS .
> 4. []+[] returns string.here + triggers coercion converting both[] to ""
> 5. the next is 0=="0" ,0==[] but "0"!=[]

# Sub Task 2
## Assignment
```
//A function that returns something
function hell(){
    console.log("you are in hell ")
}
hell();
```

```
// A function that returns noting
functon fun(){ }
```


```
//A function that has parameters with default values
function hellname(name,place="hell"){
    console.log(`you are in ${place} ${name}`);
}
hellname("myself");
```

## Challenges
> From what i have read till now Function is what that deals a block of code with variables while Methods deal with objects instead of variables.

# Sub Task 3

## Assignment
```
let allStudents = ['A','B-',1,4,5, 2]

let studentsWhoPass = [];
let l=['A','A-','B','B-','C'];
for(let i=0;i<allStudents.length;i++){
if(l.includes(allStudents[i])){
studentsWhoPass.push(allStudents[i]); 
}
else if(typeof allStudents[i] ==="number" && allStudents[i]>=3){ 
studentsWhoPass.push(allStudents[i]); 
}
}

console.log(studentsWhoPass);
```


## Challenges
```let a=5;
let b=6;
let x;
if(a>=b){
x=a;
}
else{
x=b;
}

x = a>=b ? a : b ;
```
# Sub Task 4
## Assignment
```let x=[];
for(i=1;i<=20;i++){
if(i%3==0){
console.log(i);
x.push(i)
}
}
```
## Challenge
```let x=[1,2,3,4,5,6]

console.log(x.map((y) => y))

for (y of x){
console.log(y);
}

```
