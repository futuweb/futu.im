---
title: 面向对象设计原则之单一职责原则和接口隔离原则
subtitle: 单一职责原则（Single Responsibility Principle，SRP）
date: 2018-04-29 19:00
categories: [后端]
author: Arlvin
---

> 免责声明：内容由作者分享，本文编写由 [AmyLi](/author/AmyLi) 代为执笔。

单一职责原则（Single Responsibility Principle，SRP）是指一个类应该仅有一个引起它变化的原因。即类的职责要单一，不能将太多的职责放在一个类中。

<!--more-->

## 单一职责
### 定义
单一职责原则（Single Responsibility Principle，SRP）是指一个类应该仅有一个引起它变化的原因。即类的职责要单一，不能将太多的职责放在一个类中。

### 特点
* 高内聚
* 简单易理解
* 很难完全做到

### 为什么很难完全做到？
#### 区分职责
* 哪些算职责
* 职责的粒度有多大
* 职责是否需要细分

#### 应对变更
* 职责扩散（因为需求变更等原因，职责P被分化为粒度更细的职责P1和P2。简单理解，就是一个大的功能可以拆分成若干个小的独立功能）
* 是否立即重构代码

### 示例
用一个类描述动物呼吸这个场景，来说明单一职责原则。

```php
class Animal{
    protected $name;
    public function __construct($name){
        $this->name = $name;
    }
    public function breathe(){
        echo $this->name. "在陆地呼吸空气". PHP_EOL;
    }
}
public function start(){
    $animal1 = new Animal("牛");
    $animal1->breathe();
    $animal2 = new Animal("羊");
    $animal2->breathe();
}

```
运行结果：

```
牛在陆地呼吸空气
羊在陆地呼吸空气
```

程序上线后，由于需求变更等原因，发现并不是所有的动物都是在陆地呼吸空气，如鱼是在水里呼吸空气的。

#### 解决方法一

```php
class Animal{
    protected $name;
    public function __construct($name){
        $this->name = $name;
    }
    public function breathe(){
        if($this->name !== "鱼"){
            echo $this->name. "在陆地呼吸空气". PHP_EOL;
        }else{
            echo $this->name. "在水里呼吸空气". PHP_EOL;
        }
    }
}

public function start(){
    $animal1 = new Animal("牛");
    $animal1->breathe();
    $animal2 = new Animal("羊");
    $animal2->breathe();
    $animal3 = new Animal("鱼");
    $animal3->breathe();
}
```

代码级别违背了单一职责原则。这种修改方式简单，但直接对原有代码的修改会对已有功能带来风险。

#### 解决方法二

```php
class Animal{
    protected $name;
    public function __construct($name){
        $this->name = $name;
    }
    public function breathe(){
        echo $this->name. "在陆地呼吸空气". PHP_EOL;
    }
    public function breathe2(){
        echo $this->name. "在水里呼吸空气". PHP_EOL;
    }
}
public function start(){
        $animal1 = new Animal("牛");
        $animal1->breathe();
        $animal2 = new Animal("羊");
        $animal2->breathe();
        $animal3 = new Animal("鱼");
        $animal3->breathe2();
    }
```

运行结果：

```
牛在陆地呼吸空气
羊在陆地呼吸空气
鱼在水里呼吸空气
```

方法级别上符合单一职责原则。新增方法，没有改动原来的代码，不影响已有功能。

#### 解决方法三

```php
class Terrestrial{
    protected $name;
    public function __construct($name){
        $this->name = $name;
    }
    public function breathe(){
        echo $this->name. "在陆地呼吸空气". PHP_EOL;
    }
}
class Aquatic{
    protected $name;
    public function __construct($name){
        $this->name = $name;
    }
    public function breathe(){
        echo $this->name. "在水里呼吸空气". PHP_EOL;
    }
}
    public function start(){
        $animal1 = new Terrestrial("牛");
        $animal1->breathe();
        $animal2 = new Terrestrial("羊");
        $animal2->breathe();
        $animal3 = new Aquatic("鱼");
        $animal3->breathe();
    }
```

符合单一职责原则。重构原有代码，除了将原来的类分解以外，还要修改调用方，花销很大。

### 遵循单一职责原则的优点
* 降低类的复杂性
* 提高类的可读性
* 变更引起的风险降低

### 单一职责原则扩展
不仅仅是类，方法，数据库表字段，甚至是变量等也需要做到职责的分离。

## 接口隔离
### 定义
* 第一种定义：客户端不应该依赖它不需要的接口 
* 第二种定义：类间的依赖关系应该建立在最小的接口上 
* 通俗的定义：接口尽量细化，同时接口中的方法尽量少。

### 示例
举一个跟动物有关的接口，说明接口隔离原则。

```php
interface IAnimal{
    public function walk();
    public function speak();
}
class Dog implements IAnimal{
    public function walk(){
        echo "dogs can walk";
    }
    public function speak(){
        echo "dogs can speak";
    }
}
```

想创建一个鱼类，修改接口。

```php
interface IAnimal{
    public function walk();
    public function speak();
    public function swim();
}
class Dog implements IAnimal{
    public function walk(){
        echo "dogs can walk";
    }
    public function speak(){
        echo "dogs can speak";
    }
    public function swim(){
         
    }
}
class Fish implements IAnimal{
    public function walk(){
    }
    public function speak(){
    }
    public function swim(){
        echo "fish can swim";
    }
}
```

#### 解决方法
接口细化即可，将IAnimal接口类拆分成三个接口类。

```php
interface IAnimalCanWalk{
    public function walk();
}
interface IAnimalCanSpeak{
    public function speak();
}
interface IAnimalCanSwim{
    public function swim();
}
class Dog implements IAnimalCanWalk, IAnimalCanSpeak{
    public function walk(){
        echo "dogs can walk";
    }
    public function speak(){
        echo "dogs can speak";
    }
}

class Fish implements IAnimalCanSwim{
    public function swim(){
        echo "fish can swim";
    }
}
```

### 遵循接口隔离原则的优点
* 简洁代码
* 接口最小化
* 增加灵活性

### 注意
1.接口不能太小，会导致系统接口泛滥，不易维护
2.接口也不能太大，太大的接口违背原则，灵活性较差

