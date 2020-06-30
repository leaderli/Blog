---
title: spring循环依赖
date: 2019-08-26 23:34:14
categories: spring
tags:
  - 源码
  - spring
---

## 概述

一般只应用于单例模式,主要原理是将 bean 先缓存在 beanfactory,`prototype`无法解决循环依赖问题。
示例代码

```java
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class A {

    @Autowired
    B b;

    public A() {
        System.out.println("-------------A------------------");
    }
    @PostConstruct
    public void log(){

        System.out.println("-------------B PostConstruct------------------");
    }
}

@Component
public class B {

    @Autowired
    A a;
    public B() {
        System.out.println("-------------A------------------");
    }
    @PostConstruct
    public void log(){

        System.out.println("-------------B PostConstruct------------------");
    }
}

```

`getBean(A)`->`instance(A)`->`autowired(B)`->`getBean(B)`->`instance(B)`->`autowired(A)`->循环依赖

解决方案： 1.`A`首先调用构造函数`newInstance`，此时`A`的引用值已确定

2.  将`A`的引用缓存，创建`B`时直接使用缓存的`A`的引用

则实际实例化过程大致如下：

`getBean(A)`->`instance(A)`->`cache reference(A)`->`autowired(B)`->`getBean(B)`->`instance(B)`->`autowired(A)`->`get reference(A)`->`postConstruct(B)`->`postConstruct(A)`

## 源码分析

以`AnnotationConfigApplicationContext`的加载来举例

`AppConfig`为配置类，不重要

```java
AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(AppConfig.class);
```

省略其他过程直接看刷新

```java
public AnnotationConfigApplicationContext(Class<?>... annotatedClasses) {
    this();
    register(annotatedClasses);
    refresh();
}
```

省略扫描过程，直接看 bean 加载的过程

```java
@Override
public void refresh() throws BeansException, IllegalStateException {
    synchronized (this.startupShutdownMonitor) {
        // Prepare this context for refreshing.
        prepareRefresh();

        // Tell the subclass to refresh the internal bean factory.
        ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

        // Prepare the bean factory for use in this context.
        prepareBeanFactory(beanFactory);

        try {
            // Allows post-processing of the bean factory in context subclasses.
            postProcessBeanFactory(beanFactory);

            // Invoke factory processors registered as beans in the context.
            invokeBeanFactoryPostProcessors(beanFactory);

            // Register bean processors that intercept bean creation.
            registerBeanPostProcessors(beanFactory);

            // Initialize message source for this context.
            initMessageSource();

            // Initialize event multicaster for this context.
            initApplicationEventMulticaster();

            // Initialize other special beans in specific context subclasses.
            onRefresh();

            // Check for listener beans and register them.
            registerListeners();

            // 加载所有单例非懒加载的bean
            finishBeanFactoryInitialization(beanFactory);

            // Last step: publish corresponding event.
            finishRefresh();
        }
```

```java
protected void finishBeanFactoryInitialization(ConfigurableListableBeanFactory beanFactory) {
    // Initialize conversion service for this context.
    if (beanFactory.containsBean(CONVERSION_SERVICE_BEAN_NAME) &&
            beanFactory.isTypeMatch(CONVERSION_SERVICE_BEAN_NAME, ConversionService.class)) {
        beanFactory.setConversionService(
                beanFactory.getBean(CONVERSION_SERVICE_BEAN_NAME, ConversionService.class));
    }

    // Register a default embedded value resolver if no bean post-processor
    // (such as a PropertyPlaceholderConfigurer bean) registered any before:
    // at this point, primarily for resolution in annotation attribute values.
    if (!beanFactory.hasEmbeddedValueResolver()) {
        beanFactory.addEmbeddedValueResolver(strVal -> getEnvironment().resolvePlaceholders(strVal));
    }

    // Initialize LoadTimeWeaverAware beans early to allow for registering their transformers early.
    String[] weaverAwareNames = beanFactory.getBeanNamesForType(LoadTimeWeaverAware.class, false, false);
    for (String weaverAwareName : weaverAwareNames) {
        getBean(weaverAwareName);
    }

    // Stop using the temporary ClassLoader for type matching.
    beanFactory.setTempClassLoader(null);

    // Allow for caching all bean definition metadata, not expecting further changes.
    beanFactory.freezeConfiguration();

    // 通过debug，一般情况下使用DefaultListableBeanFactory类
    beanFactory.preInstantiateSingletons();
}
```

`DefaultListableBeanFactory`类`preInstantiateSingletons`代码片段

```java
for (String beanName : beanNames) {
    RootBeanDefinition bd = getMergedLocalBeanDefinition(beanName);
    //非抽象类，单例，非延迟加载
    if (!bd.isAbstract() && bd.isSingleton() && !bd.isLazyInit()) {
        if (isFactoryBean(beanName)) {
            Object bean = getBean(FACTORY_BEAN_PREFIX + beanName);
            if (bean instanceof FactoryBean) {
                final FactoryBean<?> factory = (FactoryBean<?>) bean;
                boolean isEagerInit;
                if (System.getSecurityManager() != null && factory instanceof SmartFactoryBean) {
                    isEagerInit = AccessController.doPrivileged((PrivilegedAction<Boolean>)
                                    ((SmartFactoryBean<?>) factory)::isEagerInit,
                            getAccessControlContext());
                }
                else {
                    isEagerInit = (factory instanceof SmartFactoryBean &&
                            ((SmartFactoryBean<?>) factory).isEagerInit());
                }
                if (isEagerInit) {
                    getBean(beanName);
                }
            }
        }
        else {
            getBean(beanName);
        }
    }
}
```

通过`getBean`方法可以追踪到`org.springframework.beans.factory.support.AbstractBeanFactory#getBean(java.lang.String)`,然后
`org.springframework.beans.factory.support.AbstractBeanFactory#doGetBean`

```java
protected <T> T doGetBean(final String name, @Nullable final Class<T> requiredType,
                            @Nullable final Object[] args, boolean typeCheckOnly) throws BeansException

    final String beanName = transformedBeanName(name);
    Object bean;

    //  单例的bean通过该方法获取
    Object sharedInstance = getSingleton(beanName);
```

`DefaultSingletonBeanRegistry`

```java
private final Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256);

public Object getSingleton(String beanName) {
    return getSingleton(beanName, true);
}

protected Object getSingleton(String beanName, boolean allowEarlyReference) {
    //我们可以清晰的看到singleton的bean简单的bean存储在ConcurrentHashMap中
    Object singletonObject = this.singletonObjects.get(beanName);
    if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
        synchronized (this.singletonObjects) {
            singletonObject = this.earlySingletonObjects.get(beanName);
            if (singletonObject == null && allowEarlyReference) {
                ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
                if (singletonFactory != null) {
                    singletonObject = singletonFactory.getObject();
                    this.earlySingletonObjects.put(beanName, singletonObject);
                    this.singletonFactories.remove(beanName);
                }
            }
        }
    }
    return singletonObject;
}
```

首次创建`A`时，`singletonObject`肯定为`null`,`isSingletonCurrentlyInCreation`的代码很简单

```java
public boolean isSingletonCurrentlyInCreation(String beanName) {
    return this.singletonsCurrentlyInCreation.contains(beanName);
}
```

我们只需要了解`singletonsCurrentlyInCreation`是何时被`add`，通过查看调用关系，最终可以发现`org.springframework.beans.factory.support.AbstractBeanFactory#doGetBean`中

```java
if (mbd.isSingleton()) {
    //getSingleton代码里调用beforeSingletonCreation方法将beanName加入singletonsCurrentlyInCreation
    //lambda表达式createBean则创建bean
    sharedInstance = getSingleton(beanName, () -> {
        try {
            return createBean(beanName, mbd, args);
        } catch (BeansException ex) {
            destroySingleton(beanName);
            throw ex;
        }
    });
    bean = getObjectForBeanInstance(sharedInstance, name, beanName, mbd);
}
```

继续回到`A`的创建，在`getSingleton`中未取到缓存是，`A`尝试`createBean`，也就是上述代码部分。
追踪调用关系可以知道最终调用`org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#createBean(java.lang.String, org.springframework.beans.factory.support.RootBeanDefinition, java.lang.Object[])`后进入`org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#doCreateBean`

节选片段

```java
protected Object doCreateBean(final String beanName, final RootBeanDefinition mbd, final @Nullable Object[] args)
        throws BeanCreationException {

    // 初始化bean
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

    boolean earlySingletonExposure = (mbd.isSingleton() && this.allowCircularReferences &&
            isSingletonCurrentlyInCreation(beanName));
    if (earlySingletonExposure) {
        if (logger.isTraceEnabled()) {
            logger.trace("Eagerly caching bean '" + beanName +
                    "' to allow for resolving potential circular references");
        }
        //将bean的引用缓存
        addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean));
    }
...
```

我们查看下`addSingletonFactory`的细节

```java
protected void addSingletonFactory(String beanName, ObjectFactory<?> singletonFactory) {
    Assert.notNull(singletonFactory, "Singleton factory must not be null");
    synchronized (this.singletonObjects) {
        if (!this.singletonObjects.containsKey(beanName)) {
            //根据beanName缓存可以取出bean的lambda中
            this.singletonFactories.put(beanName, singletonFactory);
            this.earlySingletonObjects.remove(beanName);
            this.registeredSingletons.add(beanName);
        }
    }
}
```

到这里`bean`通过构造器创建实例的过程结束了，但是`bean`在`spring`容器中的生命周期还未结束，后续发现`A`依赖`B`，则会去创建`B`，`B`在实例化后加载依赖时，会去创建`A`,不同的是在调用`DefaultSingletonBeanRegistry`的`getSingleton`时判断条件`isSingletonCurrentlyInCreation`时`A`已在创建过程中，那么就会去执行

```java
protected Object getSingleton(String beanName, boolean allowEarlyReference) {
    //我们可以清晰的看到singleton的bean简单的bean存储在ConcurrentHashMap中
    Object singletonObject = this.singletonObjects.get(beanName);
    if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
        synchronized (this.singletonObjects) {
            singletonObject = this.earlySingletonObjects.get(beanName);
            if (singletonObject == null && allowEarlyReference) {
                //根据前面的分析我们知道A的引用被缓存在此处。
                ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
                if (singletonFactory != null) {
                    singletonObject = singletonFactory.getObject();
                    this.earlySingletonObjects.put(beanName, singletonObject);
                    this.singletonFactories.remove(beanName);
                }
            }
        }
    }
    return singletonObject;
}
```

此时`B`顺利完成整个`Spring`生命周期，从而`A`也完成了整个生命周期
