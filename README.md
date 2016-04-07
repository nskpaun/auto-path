# auto-pth package

Hotkey for using the pth utility to null check an object way down in an object
hierarchy.

Let's say you have:

const bar = this.props.foo.bar;

If `foo` can be undefined then you can highlight this.props, press cmd-alt-v,
and you will have:

const bar = pth(this.props, ['foo','bar']);
