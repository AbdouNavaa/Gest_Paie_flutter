//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <gallery/gallery_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) gallery_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "GalleryPlugin");
  gallery_plugin_register_with_registrar(gallery_registrar);
}
