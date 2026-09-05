<!-- residue 骨架。按本仓事实填路径与指针。不是整文件模板。思想：../philosophy/00.md -->

# 工程标准

**现行行为认（本仓须填）。**

词 → [`CONTEXT.md`](CONTEXT.md)。ADR 仅当仓内确有难逆取舍。

## 小改默认

- 实现授权来自当轮用户。幅度跟当轮任务。做完再报告。
- 打断只为：扩/缩产品边界、不可逆、或本文件写明须确认的供应方。
- 现行行为认上条所填。
- 只报查过的路径与测试。

## 本仓结构（须填）

栈与目录约定。删除优于 dual-path。注释写类型与测试说不清的 why。

## Smells

Fowler, _Refactoring_ ch.3。每条是带标签的启发式，不是硬违规。工具已经抓的跳过。

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

## 门禁

完成 = 可观察行为闭合。声称完成时的检查 → 本仓须填一条指针。
