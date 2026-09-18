package expo.modules.alarm

/** Explicit conversion replaces Expo Record's field conversion at the JS boundary. */
internal object AlarmSchedulerArguments {
  private fun value(values: Map<String, Any?>, key: String): Any? = values[key]
  private fun invalid(key: String): Nothing = throw IllegalArgumentException("Invalid alarm field: $key")

  fun string(values: Map<String, Any?>, key: String): String? =
    value(values, key)?.let { it as? String ?: invalid(key) }

  fun boolean(values: Map<String, Any?>, key: String): Boolean? =
    value(values, key)?.let { it as? Boolean ?: invalid(key) }

  fun double(values: Map<String, Any?>, key: String): Double? =
    value(values, key)?.let {
      val number = (it as? Number)?.toDouble() ?: invalid(key)
      if (!number.isFinite()) invalid(key)
      number
    }

  fun int(values: Map<String, Any?>, key: String): Int? = double(values, key)?.let {
    if (it < Int.MIN_VALUE || it > Int.MAX_VALUE || it % 1.0 != 0.0) invalid(key)
    it.toInt()
  }

  fun intList(values: Map<String, Any?>, key: String): List<Int>? =
    value(values, key)?.let { raw ->
      (raw as? List<*>)?.map { int(mapOf(key to it), key) ?: invalid(key) } ?: invalid(key)
    }

  fun objectValue(values: Map<String, Any?>, key: String): Map<String, Any>? =
    value(values, key)?.let { raw ->
      val map = raw as? Map<*, *> ?: invalid(key)
      // React Native maps use string keys. Null fields are omitted like optional input fields.
      buildMap {
        map.forEach { (k, v) ->
          if (k !is String) invalid(key)
          if (v != null) put(k, v)
        }
      }
    }
}
