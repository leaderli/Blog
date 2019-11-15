---
title: spring_initMethod执行过程
date: 2019-11-13 22:50:12
categories: spring
tags:
  - 源码分析
  - Spring加载过程
---

## 准备

`pom`依赖，`jdk`版本为`1.8`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
<modelVersion>4.0.0</modelVersion>
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.2.1.RELEASE</version>
    <relativePath/> <!-- lookup parent from repository -->
</parent>
<groupId>com.leaderli</groupId>
<artifactId>demo</artifactId>
<version>0.0.1-SNAPSHOT</version>
<name>demo</name>
<description>Demo project for Spring Boot</description>

<properties>
    <java.version>1.8</java.version>
</properties>

<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter</artifactId>
    </dependency>

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
        <exclusions>
            <exclusion>
                <groupId>org.junit.vintage</groupId>
                <artifactId>junit-vintage-engine</artifactId>
            </exclusion>
        </exclusions>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>

</project>

```

为了方便分析`Spring`中`bean`的生命周期，我们使用`@Lazy`来注解`bean`

```java
@Component
public class BeAutowired {
    static {
        System.out.println("-------BeAutowired--------");
    }
}

@Component
@Lazy
public class Person {
    @Autowired
    BeAutowired beAutowired;
    @PostConstruct
    public void begin(){
        System.out.println(" beAutowired= " + beAutowired);
    }
}
```

我们使用测试程序来分析`person`的加载过程

```java
public static void main(String[] args) {
    String packageName = Person.class.getPackage().getName();
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(packageName);
    Person person = context.getBean(Person.class);
    System.out.println("person = " + person);
}
```

## 分析

### `doGetBean`

因为使用了`@Lazy`,所以`Person`在执行`context.getBean(Person.class)`时才加载，我们`debug`进去大致了解一下关键的加载过程

```java
//交由BeanFactory去加载
@Override
public <T> T getBean(Class<T> requiredType) throws BeansException {
    assertBeanFactoryActive();
    return getBeanFactory().getBean(requiredType);
}
```

省略中间过程，最终会调用`BeanFactory`的`doGetBean`方法

```java
public <T> T getBean(String name, @Nullable Class<T> requiredType, @Nullable Object... args)
        throws BeansException {

    return doGetBean(name, requiredType, args, false);
}
```

`doGetBean`大致流程如下：

1.  如果是单例模式的，则尝试从缓存中获取`bean`
2. 尝试从父类`BeanFactory`中加载`bean`
3. 加载依赖`bean`， `@DependsOn`注解的`bean`
4. 使用方法`createBean(beanName, mbd, args)`,加载单例 bean

`doGetBean`源码，无视其他代码，只关心我们需要了解的

```java
protected <T> T doGetBean(final String name, @Nullable final Class<T> requiredType,
        @Nullable final Object[] args, boolean typeCheckOnly) throws BeansException {

    final String beanName = transformedBeanName(name);
    Object bean;

    // 1. 如果是单例模式的，则尝试从缓存中获取bean
    Object sharedInstance = getSingleton(beanName);
    if (sharedInstance != null && args == null) {
        if (logger.isTraceEnabled()) {
            if (isSingletonCurrentlyInCreation(beanName)) {
                logger.trace("Returning eagerly cached instance of singleton bean '" + beanName +
                        "' that is not fully initialized yet - a consequence of a circular reference");
            }
            else {
                logger.trace("Returning cached instance of singleton bean '" + beanName + "'");
            }
        }
        bean = getObjectForBeanInstance(sharedInstance, name, beanName, null);
    }

    else {
        // Fail if we're already creating this bean instance:
        // We're assumably within a circular reference.
        if (isPrototypeCurrentlyInCreation(beanName)) {
            throw new BeanCurrentlyInCreationException(beanName);
        }

        // 2. 尝试从父类BeanFactory中加载bean
        BeanFactory parentBeanFactory = getParentBeanFactory();
        if (parentBeanFactory != null && !containsBeanDefinition(beanName)) {
            // Not found -> check parent.
            String nameToLookup = originalBeanName(name);
            if (parentBeanFactory instanceof AbstractBeanFactory) {
                return ((AbstractBeanFactory) parentBeanFactory).doGetBean(
                        nameToLookup, requiredType, args, typeCheckOnly);
            }
            else if (args != null) {
                // Delegation to parent with explicit args.
                return (T) parentBeanFactory.getBean(nameToLookup, args);
            }
            else if (requiredType != null) {
                // No args -> delegate to standard getBean method.
                return parentBeanFactory.getBean(nameToLookup, requiredType);
            }
            else {
                return (T) parentBeanFactory.getBean(nameToLookup);
            }
        }

        if (!typeCheckOnly) {
            markBeanAsCreated(beanName);
        }

        try {
            final RootBeanDefinition mbd = getMergedLocalBeanDefinition(beanName);
            checkMergedBeanDefinition(mbd, beanName, args);

            // 3. 加载依赖bean， @DependsOn注解的bean
            String[] dependsOn = mbd.getDependsOn();
            if (dependsOn != null) {
                for (String dep : dependsOn) {
                    if (isDependent(beanName, dep)) {
                        throw new BeanCreationException(mbd.getResourceDescription(), beanName,
                                "Circular depends-on relationship between '" + beanName + "' and '" + dep + "'");
                    }
                    registerDependentBean(dep, beanName);
                    try {
                        getBean(dep);
                    }
                    catch (NoSuchBeanDefinitionException ex) {
                        throw new BeanCreationException(mbd.getResourceDescription(), beanName,
                                "'" + beanName + "' depends on missing bean '" + dep + "'", ex);
                    }
                }
            }

            // 4. 加载单例bean
            if (mbd.isSingleton()) {
                sharedInstance = getSingleton(beanName, () -> {
                    try {
                        return createBean(beanName, mbd, args);
                    }
                    catch (BeansException ex) {
                        // Explicitly remove instance from singleton cache: It might have been put there
                        // eagerly by the creation process, to allow for circular reference resolution.
                        // Also remove any beans that received a temporary reference to the bean.
                        destroySingleton(beanName);
                        throw ex;
                    }
                });
                bean = getObjectForBeanInstance(sharedInstance, name, beanName, mbd);
            }

            else if (mbd.isPrototype()) {
                // It's a prototype -> create a new instance.
                Object prototypeInstance = null;
                try {
                    beforePrototypeCreation(beanName);
                    prototypeInstance = createBean(beanName, mbd, args);
                }
                finally {
                    afterPrototypeCreation(beanName);
                }
                bean = getObjectForBeanInstance(prototypeInstance, name, beanName, mbd);
            }

            else {
                String scopeName = mbd.getScope();
                final Scope scope = this.scopes.get(scopeName);
                if (scope == null) {
                    throw new IllegalStateException("No Scope registered for scope name '" + scopeName + "'");
                }
                try {
                    Object scopedInstance = scope.get(beanName, () -> {
                        beforePrototypeCreation(beanName);
                        try {
                            return createBean(beanName, mbd, args);
                        }
                        finally {
                            afterPrototypeCreation(beanName);
                        }
                    });
                    bean = getObjectForBeanInstance(scopedInstance, name, beanName, mbd);
                }
                catch (IllegalStateException ex) {
                    throw new BeanCreationException(beanName,
                            "Scope '" + scopeName + "' is not active for the current thread; consider " +
                            "defining a scoped proxy for this bean if you intend to refer to it from a singleton",
                            ex);
                }
            }
        }
        catch (BeansException ex) {
            cleanupAfterBeanCreationFailure(beanName);
            throw ex;
        }
    }

    // Check if required type matches the type of the actual bean instance.
    if (requiredType != null && !requiredType.isInstance(bean)) {
        try {
            T convertedBean = getTypeConverter().convertIfNecessary(bean, requiredType);
            if (convertedBean == null) {
                throw new BeanNotOfRequiredTypeException(name, requiredType, bean.getClass());
            }
            return convertedBean;
        }
        catch (TypeMismatchException ex) {
            if (logger.isTraceEnabled()) {
                logger.trace("Failed to convert bean '" + name + "' to required type '" +
                        ClassUtils.getQualifiedName(requiredType) + "'", ex);
            }
            throw new BeanNotOfRequiredTypeException(name, requiredType, bean.getClass());
        }
    }
    return (T) bean;
}
```

### `createBean`

`createBean`大致流程如下：

1. _`createBeanInstance`_,使用构造器或者工厂方法实例化`bean`
2. _`populateBean`_,对`bean`进行数据的初始化操作，比如加载`@autowire`的`bean`，`@value`的属性赋值，`@PostConstruct`方法执行等
3. _`initializeBean`_,执行`BeanDefinition`中定义的`initMethod`，一般在`xml` 配置中(`<bean class="Person" init-method="initMethod"/>`)，或者`@Bean(initMethod = "initMethod")`中定义的方法名

`createBean`源码，无视其他代码，只关心我们需要了解的

```java
protected Object doCreateBean(final String beanName, final RootBeanDefinition mbd, final @Nullable Object[] args)
        throws BeanCreationException {

    // 1. 使用构造器实例化`bean`
    BeanWrapper instanceWrapper = null;
    if (mbd.isSingleton()) {
        instanceWrapper = this.factoryBeanInstanceCache.remove(beanName);
    }
    if (instanceWrapper == null) {
        instanceWrapper = createBeanInstance(beanName, mbd, args);
    }
    final Object bean = instanceWrapper.getWrappedInstance();
    Class<?> beanType = instanceWrapper.getWrappedClass();
    if (beanType != NullBean.class) {
        mbd.resolvedTargetType = beanType;
    }

    // Allow post-processors to modify the merged bean definition.
    synchronized (mbd.postProcessingLock) {
        if (!mbd.postProcessed) {
            try {
                applyMergedBeanDefinitionPostProcessors(mbd, beanType, beanName);
            }
            catch (Throwable ex) {
                throw new BeanCreationException(mbd.getResourceDescription(), beanName,
                        "Post-processing of merged bean definition failed", ex);
            }
            mbd.postProcessed = true;
        }
    }

    //这里主要解决循环依赖的问题，这里不做深入讨论
    boolean earlySingletonExposure = (mbd.isSingleton() && this.allowCircularReferences &&
            isSingletonCurrentlyInCreation(beanName));
    if (earlySingletonExposure) {
        if (logger.isTraceEnabled()) {
            logger.trace("Eagerly caching bean '" + beanName +
                    "' to allow for resolving potential circular references");
        }
        addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean));
    }

    // Initialize the bean instance.
    Object exposedObject = bean;
    try {
        //2. 对bean进行数据的初始化操作，比如加载@autowire的bean，@value的属性赋值，@PostConstruct方法执行等
        populateBean(beanName, mbd, instanceWrapper);
        //3. 执行BeanDefinition中定义的initMethod，一般在xml配置中，或者@Bean(initMethod = "initMethod")中定义的方法名
        exposedObject = initializeBean(beanName, exposedObject, mbd);
    }
    catch (Throwable ex) {
        if (ex instanceof BeanCreationException && beanName.equals(((BeanCreationException) ex).getBeanName())) {
            throw (BeanCreationException) ex;
        }
        else {
            throw new BeanCreationException(
                    mbd.getResourceDescription(), beanName, "Initialization of bean failed", ex);
        }
    }

    if (earlySingletonExposure) {
        Object earlySingletonReference = getSingleton(beanName, false);
        if (earlySingletonReference != null) {
            if (exposedObject == bean) {
                exposedObject = earlySingletonReference;
            }
            else if (!this.allowRawInjectionDespiteWrapping && hasDependentBean(beanName)) {
                String[] dependentBeans = getDependentBeans(beanName);
                Set<String> actualDependentBeans = new LinkedHashSet<>(dependentBeans.length);
                for (String dependentBean : dependentBeans) {
                    if (!removeSingletonIfCreatedForTypeCheckOnly(dependentBean)) {
                        actualDependentBeans.add(dependentBean);
                    }
                }
                if (!actualDependentBeans.isEmpty()) {
                    throw new BeanCurrentlyInCreationException(beanName,
                            "Bean with name '" + beanName + "' has been injected into other beans [" +
                            StringUtils.collectionToCommaDelimitedString(actualDependentBeans) +
                            "] in its raw version as part of a circular reference, but has eventually been " +
                            "wrapped. This means that said other beans do not use the final version of the " +
                            "bean. This is often the result of over-eager type matching - consider using " +
                            "'getBeanNamesOfType' with the 'allowEagerInit' flag turned off, for example.");
                }
            }
        }
    }

    // Register bean as disposable.
    try {
        registerDisposableBeanIfNecessary(beanName, bean, mbd);
    }
    catch (BeanDefinitionValidationException ex) {
        throw new BeanCreationException(
                mbd.getResourceDescription(), beanName, "Invalid destruction signature", ex);
    }

    return exposedObject;
}
```

### `populateBean`

这里我们简单介绍一下`@Autowired`是何时被加载的。我们通过打断点，并设置`evaluate`语句，在断点处输出日志的方式查看  
![spring-initMethod执行过程_2019-11-14-01-27-39.png](/images/spring-initMethod执行过程_2019-11-14-01-27-39.png)

断点调试最后输出的日志如下  
![spring-initMethod执行过程_2019-11-14-01-29-22.png](/images/spring-initMethod执行过程_2019-11-14-01-29-22.png)
我们可以得知被`@Autowired`的属性或方法是否处理器`AutowiredAnnotationBeanPostProcessor`去实现的，具体加载过程参考 {% post_link Spring_Autowired源码分析 %}

```java
protected void populateBean(String beanName, RootBeanDefinition mbd, @Nullable BeanWrapper bw) {
    if (bw == null) {
        if (mbd.hasPropertyValues()) {
            throw new BeanCreationException(
                    mbd.getResourceDescription(), beanName, "Cannot apply property values to null instance");
        }
        else {
            // Skip property population phase for null instance.
            return;
        }
    }

    // Give any InstantiationAwareBeanPostProcessors the opportunity to modify the
    // state of the bean before properties are set. This can be used, for example,
    // to support styles of field injection.
    boolean continueWithPropertyPopulation = true;

    if (!mbd.isSynthetic() && hasInstantiationAwareBeanPostProcessors()) {
        for (BeanPostProcessor bp : getBeanPostProcessors()) {
            if (bp instanceof InstantiationAwareBeanPostProcessor) {
                InstantiationAwareBeanPostProcessor ibp = (InstantiationAwareBeanPostProcessor) bp;
                if (!ibp.postProcessAfterInstantiation(bw.getWrappedInstance(), beanName)) {
                    continueWithPropertyPopulation = false;
                    break;
                }
            }
        }
    }

    if (!continueWithPropertyPopulation) {
        return;
    }

    PropertyValues pvs = (mbd.hasPropertyValues() ? mbd.getPropertyValues() : null);

    int resolvedAutowireMode = mbd.getResolvedAutowireMode();
    if (resolvedAutowireMode == AUTOWIRE_BY_NAME || resolvedAutowireMode == AUTOWIRE_BY_TYPE) {
        MutablePropertyValues newPvs = new MutablePropertyValues(pvs);
        // Add property values based on autowire by name if applicable.
        if (resolvedAutowireMode == AUTOWIRE_BY_NAME) {
            autowireByName(beanName, mbd, bw, newPvs);
        }
        // Add property values based on autowire by type if applicable.
        if (resolvedAutowireMode == AUTOWIRE_BY_TYPE) {
            autowireByType(beanName, mbd, bw, newPvs);
        }
        pvs = newPvs;
    }

    boolean hasInstAwareBpps = hasInstantiationAwareBeanPostProcessors();
    boolean needsDepCheck = (mbd.getDependencyCheck() != AbstractBeanDefinition.DEPENDENCY_CHECK_NONE);

    PropertyDescriptor[] filteredPds = null;
    if (hasInstAwareBpps) {
        if (pvs == null) {
            pvs = mbd.getPropertyValues();
        }
        //对满足条件的BeanPostProcessor，执行postProcessProperties方法，对bean的属性进行赋值操作
        for (BeanPostProcessor bp : getBeanPostProcessors()) {
            if (bp instanceof InstantiationAwareBeanPostProcessor) {
                InstantiationAwareBeanPostProcessor ibp = (InstantiationAwareBeanPostProcessor) bp;
                PropertyValues pvsToUse = ibp.postProcessProperties(pvs, bw.getWrappedInstance(), beanName);
                if (pvsToUse == null) {
                    if (filteredPds == null) {
                        filteredPds = filterPropertyDescriptorsForDependencyCheck(bw, mbd.allowCaching);
                    }
                    pvsToUse = ibp.postProcessPropertyValues(pvs, filteredPds, bw.getWrappedInstance(), beanName);
                    if (pvsToUse == null) {
                        return;
                    }
                }
                pvs = pvsToUse;
            }
        }
    }
    if (needsDepCheck) {
        if (filteredPds == null) {
            filteredPds = filterPropertyDescriptorsForDependencyCheck(bw, mbd.allowCaching);
        }
        checkDependencies(beanName, mbd, filteredPds, pvs);
    }

    if (pvs != null) {
        applyPropertyValues(beanName, mbd, bw, pvs);
    }
}
```

### `initializeBean`

`initializeBean`大致执行步骤如下：

1. 若接口实现了`Aware`，则执行对应的方法
2. 执行所有`BeanPostProcessor`的`postProcessBeforeInitialization`方法
3. 执行`BeanDefinition`中定义的`init-method`
4. 执行所有`BeanPostProcessor`的`postProcessAfterInitialization`方法

```java
protected Object initializeBean(final String beanName, final Object bean, @Nullable RootBeanDefinition mbd) {
    if (System.getSecurityManager() != null) {
        AccessController.doPrivileged((PrivilegedAction<Object>) () -> {
            invokeAwareMethods(beanName, bean);
            return null;
        }, getAccessControlContext());
    }
    else {
        //1. 若接口实现了`Aware`，则执行对应的方法
        invokeAwareMethods(beanName, bean);
    }

    Object wrappedBean = bean;
    if (mbd == null || !mbd.isSynthetic()) {
        2. 执行所有`BeanPostProcessor`的`postProcessBeforeInitialization`方法
        wrappedBean = applyBeanPostProcessorsBeforeInitialization(wrappedBean, beanName);
    }

    try {
        3. 执行`BeanDefinition`中定义的`init-method`
        invokeInitMethods(beanName, wrappedBean, mbd);
    }
    catch (Throwable ex) {
        throw new BeanCreationException(
                (mbd != null ? mbd.getResourceDescription() : null),
                beanName, "Invocation of init method failed", ex);
    }
    if (mbd == null || !mbd.isSynthetic()) {
        4. 执行所有`BeanPostProcessor`的`postProcessAfterInitialization`方法
        wrappedBean = applyBeanPostProcessorsAfterInitialization(wrappedBean, beanName);
    }

    return wrappedBean;
}
```

我们对上述`initializeBean`的第三步骤不做过多介绍，其大致执行过程为在初始化`BeanDefinition`时，将`initMethod`的值通过下述方法加载

```java
void setInitMethodName(@Nullable String initMethodName);
```

然后`initializeBean`通过`invokeInitMethods`来执行`initMethod`

#### applyBeanPostProcessorsBeforeInitialization

我们同样通过断点调试的方式来观察，`@PostConstruct`方法是何时被执行的  
![spring-initMethod执行过程_2019-11-14-01-45-47.png](/images/spring-initMethod执行过程_2019-11-14-01-45-47.png)
我们可以得知是在`CommonAnnotationBeanPostProcessor`中被处理的

我们查看其源码

```java
@Override
public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
    //查找是否有@PostConstruct注解的方法
    LifecycleMetadata metadata = findLifecycleMetadata(bean.getClass());
    try {
        //执行所有被注解了@PostConstruct的方法
        metadata.invokeInitMethods(bean, beanName);
    }
    catch (InvocationTargetException ex) {
        throw new BeanCreationException(beanName, "Invocation of init method failed", ex.getTargetException());
    }
    catch (Throwable ex) {
        throw new BeanCreationException(beanName, "Failed to invoke init method", ex);
    }
    return bean;
}
```

查看`findLifecycleMetadata`-->`buildLifecycleMetadata`细节  
我们只需要了解`this.initAnnotationType`, `this.destroyAnnotationType`的赋值情况即可

```java
private LifecycleMetadata buildLifecycleMetadata(final Class<?> clazz) {
    //是否有指定注解的方法存在
    if (!AnnotationUtils.isCandidateClass(clazz, Arrays.asList(this.initAnnotationType, this.destroyAnnotationType))) {
        return this.emptyLifecycleMetadata;
    }

    List<LifecycleElement> initMethods = new ArrayList<>();
    List<LifecycleElement> destroyMethods = new ArrayList<>();
    Class<?> targetClass = clazz;

    do {
        final List<LifecycleElement> currInitMethods = new ArrayList<>();
        final List<LifecycleElement> currDestroyMethods = new ArrayList<>();

        ReflectionUtils.doWithLocalMethods(targetClass, method -> {
            if (this.initAnnotationType != null && method.isAnnotationPresent(this.initAnnotationType)) {
                LifecycleElement element = new LifecycleElement(method);
                currInitMethods.add(element);
                if (logger.isTraceEnabled()) {
                    logger.trace("Found init method on class [" + clazz.getName() + "]: " + method);
                }
            }
            if (this.destroyAnnotationType != null && method.isAnnotationPresent(this.destroyAnnotationType)) {
                currDestroyMethods.add(new LifecycleElement(method));
                if (logger.isTraceEnabled()) {
                    logger.trace("Found destroy method on class [" + clazz.getName() + "]: " + method);
                }
            }
        });
        //将扫描到的init,destroy方法放入LifecycleMetadata
        initMethods.addAll(0, currInitMethods);
        destroyMethods.addAll(currDestroyMethods);
        targetClass = targetClass.getSuperclass();
    }
    while (targetClass != null && targetClass != Object.class);

    return (initMethods.isEmpty() && destroyMethods.isEmpty() ? this.emptyLifecycleMetadata :
            new LifecycleMetadata(clazz, initMethods, destroyMethods));
}

```

我们通过查看`CommonAnnotationBeanPostProcessor`的构造器发现了`@PostConstruct`的赋值过程。

```java
public CommonAnnotationBeanPostProcessor() {
    setOrder(Ordered.LOWEST_PRECEDENCE - 3);
    setInitAnnotationType(PostConstruct.class);
    setDestroyAnnotationType(PreDestroy.class);
    ignoreResourceType("javax.xml.ws.WebServiceContext");
}
```
