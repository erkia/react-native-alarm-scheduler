import type { AlarmSchedulerModuleEvents } from './AlarmScheduler.types';

type EventName = keyof AlarmSchedulerModuleEvents;
type Subscription = { remove(): void };
type Listener = { callback: (payload: never) => void };
type NativeEvents = {
  onAlarmEvent(callback: (event: { name: string; payload: object }) => void): Subscription;
  setObserving(event: string, observing: boolean): void;
};

/** Keeps the existing Expo-style subscription API without an Expo runtime. */
export class AlarmSchedulerEventEmitter {
  private listeners = new Map<EventName, Set<Listener>>();
  private nativeSubscription?: Subscription;

  constructor(private readonly nativeEvents?: NativeEvents) {}

  addListener<E extends EventName>(
    name: E,
    callback: AlarmSchedulerModuleEvents[E],
  ): Subscription {
    let listeners = this.listeners.get(name);
    if (!listeners) {
      listeners = new Set();
      this.listeners.set(name, listeners);
    }
    const entry = { callback: callback as Listener['callback'] };
    listeners.add(entry);
    if (!this.nativeSubscription && this.nativeEvents) {
      this.nativeSubscription = this.nativeEvents.onAlarmEvent(({ name, payload }) => {
        this.dispatch(name as EventName, payload);
      });
    }
    if (listeners.size === 1) this.nativeEvents?.setObserving(name, true);
    return { remove: () => this.removeEntry(name, entry) };
  }

  removeListener<E extends EventName>(name: E, callback: AlarmSchedulerModuleEvents[E]): void {
    for (const entry of this.listeners.get(name) ?? []) {
      if (entry.callback === callback) this.removeEntry(name, entry);
    }
  }

  removeAllListeners(name: EventName): void {
    for (const entry of this.listeners.get(name) ?? []) this.removeEntry(name, entry);
  }

  listenerCount(name: EventName): number {
    return this.listeners.get(name)?.size ?? 0;
  }

  emit<E extends EventName>(name: E, payload: Parameters<AlarmSchedulerModuleEvents[E]>[0]): void {
    this.dispatch(name, payload);
  }

  private dispatch(name: EventName, payload: object): void {
    for (const entry of [...(this.listeners.get(name) ?? [])]) {
      entry.callback(payload as never);
    }
  }

  private removeEntry(name: EventName, entry: Listener): void {
    const listeners = this.listeners.get(name);
    if (!listeners?.delete(entry)) return;
    if (listeners.size === 0) {
      this.listeners.delete(name);
      this.nativeEvents?.setObserving(name, false);
    }
    if (this.listeners.size === 0) {
      this.nativeSubscription?.remove();
      this.nativeSubscription = undefined;
    }
  }
}
