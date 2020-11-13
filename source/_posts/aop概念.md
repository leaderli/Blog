---
title: aop概念
date: 2019-09-04 22:58:38
categories: java
tags:
  - spring
  - aop
---

## 术语

1. 连接点 `Join Point` java 运行过程中的位置，对于`Spring`来说，表示允许使用切面的位置，它一般是指方法运行的过程，比如运行前，运行后，抛出异常等。
2. 通知 `Advice` 在某连接点上执行的特殊操作
3. 切入点 `PointCut` 切入点通过表达式来连接通知和连接点，确定连接点是否符合切入点表达式
4. 目标类 `Target` 被切面切入的类
5. 代理类 `AOP proxy` 实现切面的方式即实现目标类的代理类对象，对于`Spring`来说，通过`JDK`动态代理和`CGLIB`字节码代理
6. 织入 `Weaving` 把切面应用到目标对象来创建新的代理对象的过程

## `JDK`动态代理

`JDK`动态代理仅支持代理接口(因为代理类继承`Proxy`，而`java`不支持多继承)。 由`JDK`动态生成继承接口的子类，子类的所有方法调用都由创建代理类时使用的参数`java.lang.reflect.InvocationHandler`的`invoke`方法去完成。

```java
package com.li.springboot.aop;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.function.Supplier;

public class DJKProxy<T> implements InvocationHandler {

    private T t;

    public DJKProxy(T t) {
        this.t = t;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println("method = " + method);
        return method.invoke(t, args);
    }

    public static void main(String[] args) {
        //设置为true时，将会在项目跟目录生成代理类的源码
        System.getProperties().put("sun.misc.ProxyGenerator.saveGeneratedFiles", "true");
        Supplier supplier = () -> 1;
        DJKProxy<Supplier> proxy = new DJKProxy<>(supplier);
        Supplier proxyInstance = (Supplier) Proxy.newProxyInstance(DJKProxy.class.getClassLoader(), supplier.getClass().getInterfaces(), proxy);
        Object result = proxyInstance.get();
        System.out.println("proxyInstance = " + proxyInstance);
        System.out.println("result = " + result);
    }
}

```

下面是自动生成的代理类反编译的源码

```java
//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package com.sun.proxy;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.lang.reflect.UndeclaredThrowableException;
import java.util.function.Supplier;

public final class $Proxy0 extends Proxy implements Supplier {
    private static Method m1;
    private static Method m2;
    private static Method m3;
    private static Method m0;

    public $Proxy0(InvocationHandler var1) throws  {
        super(var1);
    }

    public final boolean equals(Object var1) throws  {
        try {
            return (Boolean)super.h.invoke(this, m1, new Object[]{var1});
        } catch (RuntimeException | Error var3) {
            throw var3;
        } catch (Throwable var4) {
            throw new UndeclaredThrowableException(var4);
        }
    }

    public final String toString() throws  {
        try {
            return (String)super.h.invoke(this, m2, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    public final Object get() throws  {
        try {
            return (Object)super.h.invoke(this, m3, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    public final int hashCode() throws  {
        try {
            return (Integer)super.h.invoke(this, m0, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    static {
        try {
            m1 = Class.forName("java.lang.Object").getMethod("equals", Class.forName("java.lang.Object"));
            m2 = Class.forName("java.lang.Object").getMethod("toString");
            m3 = Class.forName("java.util.function.Supplier").getMethod("get");
            m0 = Class.forName("java.lang.Object").getMethod("hashCode");
        } catch (NoSuchMethodException var2) {
            throw new NoSuchMethodError(var2.getMessage());
        } catch (ClassNotFoundException var3) {
            throw new NoClassDefFoundError(var3.getMessage());
        }
    }
}
```

我们可以看到实际所有方法的调用都由`InvocationHandler`去调用，我们查看下`Proxy.newProxyInstance`的细节

```java
 public static Object newProxyInstance(ClassLoader loader,
                                          Class<?>[] interfaces,
                                          InvocationHandler h)
        throws IllegalArgumentException
    {
        Objects.requireNonNull(h);

        final Class<?>[] intfs = interfaces.clone();
        final SecurityManager sm = System.getSecurityManager();
        if (sm != null) {
            checkProxyAccess(Reflection.getCallerClass(), loader, intfs);
        }

        /*
         *  获取代理类class类型，也就是动态生成代理类的过程
         */
        Class<?> cl = getProxyClass0(loader, intfs);

        /*
         * Invoke its constructor with the designated invocation handler.
         */
        try {
            if (sm != null) {
                checkNewProxyPermission(Reflection.getCallerClass(), cl);
            }
            /**
             * 获取使用InvocationHandler作为参数的构造器，并且实例化
             */
            final Constructor<?> cons = cl.getConstructor(constructorParams);
            final InvocationHandler ih = h;
            if (!Modifier.isPublic(cl.getModifiers())) {
                AccessController.doPrivileged(new PrivilegedAction<Void>() {
                    public Void run() {
                        cons.setAccessible(true);
                        return null;
                    }
                });
            }
            return cons.newInstance(new Object[]{h});
        } catch (IllegalAccessException|InstantiationException e) {
            throw new InternalError(e.toString(), e);
        } catch (InvocationTargetException e) {
            Throwable t = e.getCause();
            if (t instanceof RuntimeException) {
                throw (RuntimeException) t;
            } else {
                throw new InternalError(t.toString(), t);
            }
        } catch (NoSuchMethodException e) {
            throw new InternalError(e.toString(), e);
        }
    }

```

```java
 private static final WeakCache<ClassLoader, Class<?>[], Class<?>>
        proxyClassCache = new WeakCache<>(new KeyFactory(), new ProxyClassFactory());

private static Class<?> getProxyClass0(ClassLoader loader,
                                        Class<?>... interfaces) {
    if (interfaces.length > 65535) {
        throw new IllegalArgumentException("interface limit exceeded");
    }
    //根据接口返回代理类，当前classloader已经存在则直接返回缓存
    return proxyClassCache.get(loader, interfaces);
}
```

```java
public V get(K key, P parameter) {
    Objects.requireNonNull(parameter);

    expungeStaleEntries();

    Object cacheKey = CacheKey.valueOf(key, refQueue);

    ConcurrentMap<Object, Supplier<V>> valuesMap = map.get(cacheKey);
    if (valuesMap == null) {
        ConcurrentMap<Object, Supplier<V>> oldValuesMap
            = map.putIfAbsent(cacheKey,
                                valuesMap = new ConcurrentHashMap<>());
        if (oldValuesMap != null) {
            valuesMap = oldValuesMap;
        }
    }

    Object subKey = Objects.requireNonNull(subKeyFactory.apply(key, parameter));
    Supplier<V> supplier = valuesMap.get(subKey);
    Factory factory = null;

    while (true) {
        if (supplier != null) {
            V value = supplier.get();
            if (value != null) {
                return value;
            }
        }
        if (factory == null) {
            factory = new Factory(key, parameter, subKey, valuesMap);
        }

        if (supplier == null) {
            supplier = valuesMap.putIfAbsent(subKey, factory);
            if (supplier == null) {
                supplier = factory;
            }
        } else {
            if (valuesMap.replace(subKey, supplier, factory)) {
                supplier = factory;
            } else {
                supplier = valuesMap.get(subKey);
            }
        }
    }
}

```

通过断点`debug`，我们可以得出`supplier`的类为`class java.lang.reflect.WeakCache$Factory`,查看其`get`方法，

```java
public synchronized V get() { // serialize access
    // re-check
    Supplier<V> supplier = valuesMap.get(subKey);
    if (supplier != this) {
        // the loop
        return null;
    }
    V value = null;
    try {
        //根据上面的代码可知valueFactory为ProxyClassFactory
        value = Objects.requireNonNull(valueFactory.apply(key, parameter));
    } finally {
        if (value == null) { // remove us on failure
            valuesMap.remove(subKey, this);
        }
    }
    assert value != null;

    CacheValue<V> cacheValue = new CacheValue<>(value);

    if (valuesMap.replace(subKey, this, cacheValue)) {
        reverseMap.put(cacheValue, Boolean.TRUE);
    } else {
        throw new AssertionError("Should not reach here");
    }
    return value;
}
```

查看`ProxyClassFactory`的`apply`方法，

```java
@Override
public Class<?> apply(ClassLoader loader, Class<?>[] interfaces) {

    Map<Class<?>, Boolean> interfaceSet = new IdentityHashMap<>(interfaces.length);
    for (Class<?> intf : interfaces) {
        Class<?> interfaceClass = null;
        try {
            interfaceClass = Class.forName(intf.getName(), false, loader);
        } catch (ClassNotFoundException e) {
        }
        if (interfaceClass != intf) {
            throw new IllegalArgumentException(
                intf + " is not visible from class loader");
        }
        if (!interfaceClass.isInterface()) {
            throw new IllegalArgumentException(
                interfaceClass.getName() + " is not an interface");
        }
        if (interfaceSet.put(interfaceClass, Boolean.TRUE) != null) {
            throw new IllegalArgumentException(
                "repeated interface: " + interfaceClass.getName());
        }
    }

    String proxyPkg = null;     // package to define proxy class in
    int accessFlags = Modifier.PUBLIC | Modifier.FINAL;

    for (Class<?> intf : interfaces) {
        int flags = intf.getModifiers();
        if (!Modifier.isPublic(flags)) {
            accessFlags = Modifier.FINAL;
            String name = intf.getName();
            int n = name.lastIndexOf('.');
            String pkg = ((n == -1) ? "" : name.substring(0, n + 1));
            if (proxyPkg == null) {
                proxyPkg = pkg;
            } else if (!pkg.equals(proxyPkg)) {
                throw new IllegalArgumentException(
                    "non-public interfaces from different packages");
            }
        }
    }

    if (proxyPkg == null) {
        proxyPkg = ReflectUtil.PROXY_PACKAGE + ".";
    }

    long num = nextUniqueNumber.getAndIncrement();
    //代理类的类名 com.sun.proxy. + $Proxy + 1
    String proxyName = proxyPkg + proxyClassNamePrefix + num;

    byte[] proxyClassFile = ProxyGenerator.generateProxyClass(
        proxyName, interfaces, accessFlags);
    try {
        //加载类
        return defineClass0(loader, proxyName,
                            proxyClassFile, 0, proxyClassFile.length);
    } catch (ClassFormatError e) {
        throw new IllegalArgumentException(e.toString());
    }
}
```

```java
 private final static boolean saveGeneratedFiles =java.security.AccessController.doPrivileged(new GetBooleanAction("sun.misc.ProxyGenerator.saveGeneratedFiles")).booleanValue();
public static byte[] generateProxyClass(final String name, Class<?>[] interfaces,int accessFlags){
    ProxyGenerator gen = new ProxyGenerator(name, interfaces, accessFlags);
    //生成类
    final byte[] classFile = gen.generateClassFile();

    if (saveGeneratedFiles) {//根据sun.misc.ProxyGenerator.saveGeneratedFiles决定是否输出代理类的文件
        java.security.AccessController.doPrivileged(
        new java.security.PrivilegedAction<Void>() {
            public Void run() {
                try {
                    int i = name.lastIndexOf('.');
                    Path path;
                    if (i > 0) {
                        Path dir = Paths.get(name.substring(0, i).replace('.', File.separatorChar));
                        Files.createDirectories(dir);
                        path = dir.resolve(name.substring(i+1, name.length()) + ".class");
                    } else {
                        path = Paths.get(name + ".class");
                    }
                    Files.write(path, classFile);
                    return null;
                } catch (IOException e) {
                    throw new InternalError(
                        "I/O exception saving generated file: " + e);
                }
            }
        });
    }

    return classFile;
}

```

```java
private byte[] generateClassFile() {

    /*
     * 注册Object方法的代理方法
     */
    addProxyMethod(hashCodeMethod, Object.class);
    addProxyMethod(equalsMethod, Object.class);
    addProxyMethod(toStringMethod, Object.class);

    /*
     * 注解接口方法的代理方法
     */
    for (Class<?> intf : interfaces) {
        for (Method m : intf.getMethods()) {
            addProxyMethod(m, intf);
        }
    }

    for (List<ProxyMethod> sigmethods : proxyMethods.values()) {
        checkReturnTypes(sigmethods);
    }

    try {
        // 生成默认构造器
        methods.add(generateConstructor());

        for (List<ProxyMethod> sigmethods : proxyMethods.values()) {
            for (ProxyMethod pm : sigmethods) {

                // 生成静态变量target方法
                fields.add(new FieldInfo(pm.methodFieldName,
                    "Ljava/lang/reflect/Method;",
                        ACC_PRIVATE | ACC_STATIC));

                // 生成代理方法细节，即交由InvocationHandler调用，参数使用了静态属性target方法
                methods.add(pm.generateMethod());
            }
        }

        methods.add(generateStaticInitializer());

    } catch (IOException e) {
        throw new InternalError("unexpected I/O Exception", e);
    }

    if (methods.size() > 65535) {
        throw new IllegalArgumentException("method limit exceeded");
    }
    if (fields.size() > 65535) {
        throw new IllegalArgumentException("field limit exceeded");
    }

    cp.getClass(dotToSlash(className));
    cp.getClass(superclassName);
    for (Class<?> intf: interfaces) {
        cp.getClass(dotToSlash(intf.getName()));
    }
    cp.setReadOnly();
    ByteArrayOutputStream bout = new ByteArrayOutputStream();
    DataOutputStream dout = new DataOutputStream(bout);

    try {
                                    // u4 magic;
        dout.writeInt(0xCAFEBABE);
                                    // u2 minor_version;
        dout.writeShort(CLASSFILE_MINOR_VERSION);
                                    // u2 major_version;
        dout.writeShort(CLASSFILE_MAJOR_VERSION);

        cp.write(dout);             // (write constant pool)

                                    // u2 access_flags;
        dout.writeShort(accessFlags);
                                    // u2 this_class;
        dout.writeShort(cp.getClass(dotToSlash(className)));
                                    // u2 super_class;
        dout.writeShort(cp.getClass(superclassName));

                                    // u2 interfaces_count;
        dout.writeShort(interfaces.length);
                                    // u2 interfaces[interfaces_count];
        for (Class<?> intf : interfaces) {
            dout.writeShort(cp.getClass(
                dotToSlash(intf.getName())));
        }

                                    // u2 fields_count;
        dout.writeShort(fields.size());
                                    // field_info fields[fields_count];
        for (FieldInfo f : fields) {
            f.write(dout);
        }

                                    // u2 methods_count;
        dout.writeShort(methods.size());
                                    // method_info methods[methods_count];
        for (MethodInfo m : methods) {
            m.write(dout);
        }

                                        // u2 attributes_count;
        dout.writeShort(0); // (no ClassFile attributes for proxy classes)

    } catch (IOException e) {
        throw new InternalError("unexpected I/O Exception", e);
    }

    return bout.toByteArray();
}

```

```java
/**
 * 根据方法名，方法参数类型，方法返回类型，抛出异常来给fromClass增加方法
 */
private void addProxyMethod(Method m, Class<?> fromClass) {
    String name = m.getName();
    Class<?>[] parameterTypes = m.getParameterTypes();
    Class<?> returnType = m.getReturnType();
    Class<?>[] exceptionTypes = m.getExceptionTypes();

    String sig = name + getParameterDescriptors(parameterTypes);
    List<ProxyMethod> sigmethods = proxyMethods.get(sig);
    if (sigmethods != null) {
        for (ProxyMethod pm : sigmethods) {
            if (returnType == pm.returnType) {
                List<Class<?>> legalExceptions = new ArrayList<>();
                collectCompatibleTypes( exceptionTypes, pm.exceptionTypes, legalExceptions);
                collectCompatibleTypes( pm.exceptionTypes, exceptionTypes, legalExceptions);
                pm.exceptionTypes = new Class<?>[legalExceptions.size()];
                pm.exceptionTypes = legalExceptions.toArray(pm.exceptionTypes);
                return;
            }
        }
    } else {
        sigmethods = new ArrayList<>(3);
        proxyMethods.put(sig, sigmethods);
    }
    sigmethods.add(new ProxyMethod(name, parameterTypes, returnType, exceptionTypes, fromClass));
}
```

### 为接口实现一个默认类

```java
static <T> T beanInstance(Class<T> _interface, Object ... args) {
    //...
    return null;
}

static <T> T plugin(Class<T> _interface, Object ... args) {

    if (_interface.isInterface()) {
        T target = beanInstance(_interface, args);

        InvocationHandler invocationHandler = null;
        if (target == null) {
            invocationHandler = (proxy, method, params) -> null;
        } else {
            invocationHandler = (proxy, method, params) -> method.invoke(target, params);

        }
        return _interface.cast(Proxy.newProxyInstance(ClassLoader.getSystemClassLoader(), new Class[]{_interface}, invocationHandler));
    }
    throw new IllegalArgumentException("only support interface plugin");

}


public static void main(String[] args) {
    // 即使没有实现类，也不影响接口调用
    InterfaceClass plugin = plugin(InterfaceClass.class);
    plugin.test("hello");
}
```

> InvocationHandler 针对 void 方法，可以直接返回 null

## `CGLIB`字节码代理

示例

```java
import org.springframework.cglib.proxy.Enhancer;
import org.springframework.cglib.proxy.MethodInterceptor;

public class CGlibProxy {
    public static void main(String[] args) {
        //在指定目录下生成代理类的class文件
        System.setProperty(DebuggingClassWriter.DEBUG_LOCATION_PROPERTY, "/Users/li/Downloads");
        Enhancer enhancer = new Enhancer();
        enhancer.setSuperclass(Target.class);
        enhancer.setCallback((MethodInterceptor) (target, method, objects, methodProxy) -> {
            System.out.println("method : " + method);
            return methodProxy.invokeSuper(target, args);
        });
        Target target = (Target) enhancer.create();
        target.log();
    }

}

public class Target {
    public void log() {
        System.out.println("target");
    }
}
```

反编译生成的字节码

```java
//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package com.li.springboot.aop;

import java.lang.reflect.Method;
import net.sf.cglib.core.ReflectUtils;
import net.sf.cglib.core.Signature;
import net.sf.cglib.proxy.Callback;
import net.sf.cglib.proxy.Factory;
import net.sf.cglib.proxy.MethodInterceptor;
import net.sf.cglib.proxy.MethodProxy;

public class Target$$EnhancerByCGLIB$$1d0dbdbc extends Target implements Factory {
    private boolean CGLIB$BOUND;
    public static Object CGLIB$FACTORY_DATA;
    private static final ThreadLocal CGLIB$THREAD_CALLBACKS;
    private static final Callback[] CGLIB$STATIC_CALLBACKS;
    private MethodInterceptor CGLIB$CALLBACK_0;
    private static Object CGLIB$CALLBACK_FILTER;
    private static final Method CGLIB$log$0$Method;
    private static final MethodProxy CGLIB$log$0$Proxy;
    private static final Object[] CGLIB$emptyArgs;
    private static final Method CGLIB$equals$1$Method;
    private static final MethodProxy CGLIB$equals$1$Proxy;
    private static final Method CGLIB$toString$2$Method;
    private static final MethodProxy CGLIB$toString$2$Proxy;
    private static final Method CGLIB$hashCode$3$Method;
    private static final MethodProxy CGLIB$hashCode$3$Proxy;
    private static final Method CGLIB$clone$4$Method;
    private static final MethodProxy CGLIB$clone$4$Proxy;

    static void CGLIB$STATICHOOK1() {
        CGLIB$THREAD_CALLBACKS = new ThreadLocal();
        CGLIB$emptyArgs = new Object[0];
        Class var0 = Class.forName("com.li.springboot.aop.Target$$EnhancerByCGLIB$$1d0dbdbc");
        Class var1;
        Method[] var10000 = ReflectUtils.findMethods(new String[]{"equals", "(Ljava/lang/Object;)Z", "toString", "()Ljava/lang/String;", "hashCode", "()I", "clone", "()Ljava/lang/Object;"}, (var1 = Class.forName("java.lang.Object")).getDeclaredMethods());
        CGLIB$equals$1$Method = var10000[0];
        CGLIB$equals$1$Proxy = MethodProxy.create(var1, var0, "(Ljava/lang/Object;)Z", "equals", "CGLIB$equals$1");
        CGLIB$toString$2$Method = var10000[1];
        CGLIB$toString$2$Proxy = MethodProxy.create(var1, var0, "()Ljava/lang/String;", "toString", "CGLIB$toString$2");
        CGLIB$hashCode$3$Method = var10000[2];
        CGLIB$hashCode$3$Proxy = MethodProxy.create(var1, var0, "()I", "hashCode", "CGLIB$hashCode$3");
        CGLIB$clone$4$Method = var10000[3];
        CGLIB$clone$4$Proxy = MethodProxy.create(var1, var0, "()Ljava/lang/Object;", "clone", "CGLIB$clone$4");
        CGLIB$log$0$Method = ReflectUtils.findMethods(new String[]{"log", "()V"}, (var1 = Class.forName("com.li.springboot.aop.Target")).getDeclaredMethods())[0];
        CGLIB$log$0$Proxy = MethodProxy.create(var1, var0, "()V", "log", "CGLIB$log$0");
    }

    final void CGLIB$log$0() {
        super.log();
    }

    public final void log() {
        MethodInterceptor var10000 = this.CGLIB$CALLBACK_0;
        if (var10000 == null) {
            CGLIB$BIND_CALLBACKS(this);
            var10000 = this.CGLIB$CALLBACK_0;
        }

        if (var10000 != null) {
            var10000.intercept(this, CGLIB$log$0$Method, CGLIB$emptyArgs, CGLIB$log$0$Proxy);
        } else {
            super.log();
        }
    }

    final boolean CGLIB$equals$1(Object var1) {
        return super.equals(var1);
    }

    public final boolean equals(Object var1) {
        MethodInterceptor var10000 = this.CGLIB$CALLBACK_0;
        if (var10000 == null) {
            CGLIB$BIND_CALLBACKS(this);
            var10000 = this.CGLIB$CALLBACK_0;
        }

        if (var10000 != null) {
            Object var2 = var10000.intercept(this, CGLIB$equals$1$Method, new Object[]{var1}, CGLIB$equals$1$Proxy);
            return var2 == null ? false : (Boolean)var2;
        } else {
            return super.equals(var1);
        }
    }

    final String CGLIB$toString$2() {
        return super.toString();
    }

    public final String toString() {
        MethodInterceptor var10000 = this.CGLIB$CALLBACK_0;
        if (var10000 == null) {
            CGLIB$BIND_CALLBACKS(this);
            var10000 = this.CGLIB$CALLBACK_0;
        }

        return var10000 != null ? (String)var10000.intercept(this, CGLIB$toString$2$Method, CGLIB$emptyArgs, CGLIB$toString$2$Proxy) : super.toString();
    }

    final int CGLIB$hashCode$3() {
        return super.hashCode();
    }

    public final int hashCode() {
        MethodInterceptor var10000 = this.CGLIB$CALLBACK_0;
        if (var10000 == null) {
            CGLIB$BIND_CALLBACKS(this);
            var10000 = this.CGLIB$CALLBACK_0;
        }

        if (var10000 != null) {
            Object var1 = var10000.intercept(this, CGLIB$hashCode$3$Method, CGLIB$emptyArgs, CGLIB$hashCode$3$Proxy);
            return var1 == null ? 0 : ((Number)var1).intValue();
        } else {
            return super.hashCode();
        }
    }

    final Object CGLIB$clone$4() throws CloneNotSupportedException {
        return super.clone();
    }

    protected final Object clone() throws CloneNotSupportedException {
        MethodInterceptor var10000 = this.CGLIB$CALLBACK_0;
        if (var10000 == null) {
            CGLIB$BIND_CALLBACKS(this);
            var10000 = this.CGLIB$CALLBACK_0;
        }

        return var10000 != null ? var10000.intercept(this, CGLIB$clone$4$Method, CGLIB$emptyArgs, CGLIB$clone$4$Proxy) : super.clone();
    }

    public static MethodProxy CGLIB$findMethodProxy(Signature var0) {
        String var10000 = var0.toString();
        switch(var10000.hashCode()) {
        case -1097399887:
            if (var10000.equals("log()V")) {
                return CGLIB$log$0$Proxy;
            }
            break;
        case -508378822:
            if (var10000.equals("clone()Ljava/lang/Object;")) {
                return CGLIB$clone$4$Proxy;
            }
            break;
        case 1826985398:
            if (var10000.equals("equals(Ljava/lang/Object;)Z")) {
                return CGLIB$equals$1$Proxy;
            }
            break;
        case 1913648695:
            if (var10000.equals("toString()Ljava/lang/String;")) {
                return CGLIB$toString$2$Proxy;
            }
            break;
        case 1984935277:
            if (var10000.equals("hashCode()I")) {
                return CGLIB$hashCode$3$Proxy;
            }
        }

        return null;
    }

    public Target$$EnhancerByCGLIB$$1d0dbdbc() {
        CGLIB$BIND_CALLBACKS(this);
    }

    public static void CGLIB$SET_THREAD_CALLBACKS(Callback[] var0) {
        CGLIB$THREAD_CALLBACKS.set(var0);
    }

    public static void CGLIB$SET_STATIC_CALLBACKS(Callback[] var0) {
        CGLIB$STATIC_CALLBACKS = var0;
    }

    private static final void CGLIB$BIND_CALLBACKS(Object var0) {
        Target$$EnhancerByCGLIB$$1d0dbdbc var1 = (Target$$EnhancerByCGLIB$$1d0dbdbc)var0;
        if (!var1.CGLIB$BOUND) {
            var1.CGLIB$BOUND = true;
            Object var10000 = CGLIB$THREAD_CALLBACKS.get();
            if (var10000 == null) {
                var10000 = CGLIB$STATIC_CALLBACKS;
                if (var10000 == null) {
                    return;
                }
            }

            var1.CGLIB$CALLBACK_0 = (MethodInterceptor)((Callback[])var10000)[0];
        }

    }

    public Object newInstance(Callback[] var1) {
        CGLIB$SET_THREAD_CALLBACKS(var1);
        Target$$EnhancerByCGLIB$$1d0dbdbc var10000 = new Target$$EnhancerByCGLIB$$1d0dbdbc();
        CGLIB$SET_THREAD_CALLBACKS((Callback[])null);
        return var10000;
    }

    public Object newInstance(Callback var1) {
        CGLIB$SET_THREAD_CALLBACKS(new Callback[]{var1});
        Target$$EnhancerByCGLIB$$1d0dbdbc var10000 = new Target$$EnhancerByCGLIB$$1d0dbdbc();
        CGLIB$SET_THREAD_CALLBACKS((Callback[])null);
        return var10000;
    }

    public Object newInstance(Class[] var1, Object[] var2, Callback[] var3) {
        CGLIB$SET_THREAD_CALLBACKS(var3);
        Target$$EnhancerByCGLIB$$1d0dbdbc var10000 = new Target$$EnhancerByCGLIB$$1d0dbdbc;
        switch(var1.length) {
        case 0:
            var10000.<init>();
            CGLIB$SET_THREAD_CALLBACKS((Callback[])null);
            return var10000;
        default:
            throw new IllegalArgumentException("Constructor not found");
        }
    }

    public Callback getCallback(int var1) {
        CGLIB$BIND_CALLBACKS(this);
        MethodInterceptor var10000;
        switch(var1) {
        case 0:
            var10000 = this.CGLIB$CALLBACK_0;
            break;
        default:
            var10000 = null;
        }

        return var10000;
    }

    public void setCallback(int var1, Callback var2) {
        switch(var1) {
        case 0:
            this.CGLIB$CALLBACK_0 = (MethodInterceptor)var2;
        default:
        }
    }

    public Callback[] getCallbacks() {
        CGLIB$BIND_CALLBACKS(this);
        return new Callback[]{this.CGLIB$CALLBACK_0};
    }

    public void setCallbacks(Callback[] var1) {
        this.CGLIB$CALLBACK_0 = (MethodInterceptor)var1[0];
    }

    static {
        CGLIB$STATICHOOK1();
    }
}

```

具体实现细节类似`JDK`动态代理，通过某种方式生成字节码文件。

## `Spring`使用`AOP`

通过`BeanPostProcessor`返回动态代理的`bean`,

```java
@Component
public class Target {
    public void log() {
        System.out.println("target");
    }
}
```

```java
@Component
public class AOPBeanPostProcessor implements BeanPostProcessor {
    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        System.out.println("bean = " + bean);
        if(bean instanceof  Target){
        Enhancer enhancer = new Enhancer();
        enhancer.setSuperclass(bean.getClass());
        enhancer.setCallback((MethodInterceptor) (target, method, args, methodProxy) -> {
            System.out.println("BeanPostProcessor");
            return methodProxy.invokeSuper(target, args);
        });
        return enhancer.create();
        }
        return bean;
    }
}
```
