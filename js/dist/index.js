/* Generated by Opal 0.11.99.dev */
(function(Opal) {
  function $rb_minus(lhs, rhs) {
    return (typeof(lhs) === 'number' && typeof(rhs) === 'number') ? lhs - rhs : lhs['$-'](rhs);
  }
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.const_get_qualified, $$ = Opal.const_get_relative, $breaker = Opal.breaker, $slice = Opal.slice, $module = Opal.module, $klass = Opal.klass, $hash2 = Opal.hash2, $truthy = Opal.truthy, $send = Opal.send;

  Opal.add_stubs(['$use_dsl', '$on_context', '$create_block', '$[]', '$blocks', '$parse_content', '$==', '$size', '$context', '$items?', '$attr?', '$document', '$id', '$register', '$id=', '$-', '$reftext?', '$set_attr', '$<<', '$counter', '$generate_id', '$!', '$option?', '$create_open_block', '$title=', '$create_list', '$backend', '$list_item_supports_id?', '$each', '$items', '$map', '$text', '$instance_variable_get', '$text=', '$role=', '$text?', '$create_paragraph', '$blocks?', '$push', '$[]=', '$join', '$create_html_fragment', '$private', '$attributes', '$delete', '$instance_variable_defined?', '$converter', '$convert', '$tap', '$create_list_item', '$instance_variable_set', '$include?']);
  return (function($base, $parent_nesting) {
    var self = $module($base, 'Asciidoctor');

    var $nesting = [self].concat($parent_nesting);

    (function($base, $parent_nesting) {
      var self = $module($base, 'Tabs');

      var $nesting = [self].concat($parent_nesting);

      (function($base, $super, $parent_nesting) {
        var self = $klass($base, $super, 'Block');

        var $nesting = [self].concat($parent_nesting), $Block_process$1, $Block_create_html_fragment$6, $Block_generate_id$7, $Block_list_item_supports_id$ques$8;

        
        self.$use_dsl();
        self.$on_context("example");
        
        Opal.def(self, '$process', $Block_process$1 = function $$process(parent, reader, attrs) {
          var $a, $b, $$2, $$4, self = this, block = nil, children = nil, seed_tabs = nil, doc = nil, id = nil, $writer = nil, reftext = nil, tabs_number = nil, tabs_id = nil, tabs_sync = nil, tabs_role = nil, tabs = nil, tablist = nil, panes = nil, set_id_on_tab = nil;

          
          block = self.$create_block(parent, attrs['$[]']("cloaked-context"), nil, attrs, $hash2(["content_model"], {"content_model": "compound"}));
          children = self.$parse_content(block, reader).$blocks();
          if ($truthy(($truthy($a = (($b = children.$size()['$=='](1)) ? (seed_tabs = children['$[]'](0)).$context()['$==']("dlist") : children.$size()['$=='](1))) ? seed_tabs['$items?']() : $a))) {
          } else {
            return block
          };
          if ($truthy((doc = parent.$document())['$attr?']("filetype", "html"))) {
          } else {
            
            if ($truthy(seed_tabs.$id())) {
            } else {
              ($truthy($a = (id = attrs['$[]']("id"))) ? doc.$register("refs", [(($writer = [id]), $send(seed_tabs, 'id=', Opal.to_a($writer)), $writer[$rb_minus($writer["length"], 1)]), seed_tabs]) : $a)
            };
            if ($truthy(seed_tabs['$reftext?']())) {
            } else {
              ($truthy($a = (reftext = attrs['$[]']("reftext"))) ? seed_tabs.$set_attr("reftext", reftext) : $a)
            };
            parent['$<<'](seed_tabs);
            return nil;
          };
          tabs_number = doc.$counter("tabs-number");
          tabs_id = ($truthy($a = attrs['$[]']("id")) ? $a : self.$generate_id("" + "tabs " + (tabs_number), doc));
          tabs_sync = (function() {if ($truthy(($truthy($a = block['$option?']("nosync")['$!']()) ? ($truthy($b = block['$option?']("sync")) ? $b : doc['$option?']("tabs-sync")) : $a))) {
            return " is-sync"
          } else {
            return ""
          }; return nil; })();
          tabs_role = (function() {if ($truthy((tabs_role = attrs['$[]']("role")))) {
            return "" + " " + (tabs_role)
          } else {
            return ""
          }; return nil; })();
          tabs = self.$create_open_block(parent, nil, $hash2(["id", "role"], {"id": tabs_id, "role": "" + "tabs" + (tabs_sync) + (tabs_role) + " is-loading"}));
          
          $writer = [attrs['$[]']("title")];
          $send(tabs, 'title=', Opal.to_a($writer));
          $writer[$rb_minus($writer["length"], 1)];;
          tablist = self.$create_list(parent, "ulist", $hash2(["role"], {"role": "tablist"}));
          panes = $hash2([], {});
          set_id_on_tab = ($truthy($a = doc.$backend()['$==']("html5")) ? $a : self['$list_item_supports_id?'](doc));
          $send(seed_tabs.$items(), 'each', [], ($$2 = function(labels, content){var self = $$2.$$s || this, $$3, $c, $d, tab_ids = nil, tab_blocks = nil, block0 = nil, blocks = nil;

          
            
            if (labels == null) {
              labels = nil;
            };
            
            if (content == null) {
              content = nil;
            };
            tab_ids = $send(labels, 'map', [], ($$3 = function(tab){var self = $$3.$$s || this, tab_id = nil, tab_text_source = nil;

            
              
              if (tab == null) {
                tab = nil;
              };
              tablist['$<<'](tab);
              tab_id = self.$generate_id(tab.$text(), doc, tabs_id);
              tab_text_source = tab.$instance_variable_get("@text");
              if ($truthy(set_id_on_tab)) {
                
                
                $writer = [tab_id];
                $send(tab, 'id=', Opal.to_a($writer));
                $writer[$rb_minus($writer["length"], 1)];;
              } else {
                
                
                $writer = ["" + "[[" + (tab_id) + "]]" + (tab_text_source)];
                $send(tab, 'text=', Opal.to_a($writer));
                $writer[$rb_minus($writer["length"], 1)];;
              };
              
              $writer = ["tab"];
              $send(tab, 'role=', Opal.to_a($writer));
              $writer[$rb_minus($writer["length"], 1)];;
              doc.$register("refs", [tab_id, tab]).$set_attr("reftext", tab_text_source);
              return tab_id;}, $$3.$$s = self, $$3.$$arity = 1, $$3));
            if ($truthy(content)) {
              
              tab_blocks = (function() {if ($truthy(content['$text?']())) {
                return [self.$create_paragraph(parent, content.$instance_variable_get("@text"), nil, $hash2(["subs"], {"subs": "normal"}))]
              } else {
                return []
              }; return nil; })();
              if ($truthy(content['$blocks?']())) {
                
                if ($truthy(($truthy($c = (($d = (block0 = (blocks = content.$blocks())['$[]'](0)).$context()['$==']("open")) ? blocks.$size()['$=='](1) : (block0 = (blocks = content.$blocks())['$[]'](0)).$context()['$==']("open"))) ? block0['$blocks?']() : $c))) {
                  blocks = block0.$blocks()};
                $send(tab_blocks, 'push', Opal.to_a(blocks));};};
            
            $writer = [tab_ids, ($truthy($c = tab_blocks) ? $c : [])];
            $send(panes, '[]=', Opal.to_a($writer));
            return $writer[$rb_minus($writer["length"], 1)];;}, $$2.$$s = self, $$2.$$arity = 2, $$2));
          tabs['$<<'](tablist);
          $send(panes, 'each', [], ($$4 = function(tab_ids, blocks){var self = $$4.$$s || this, $$5;

          
            
            if (tab_ids == null) {
              tab_ids = nil;
            };
            
            if (blocks == null) {
              blocks = nil;
            };
            attrs = "" + " id=\"" + (tab_ids['$[]'](0)) + "--panel\" class=\"tabpanel\" aria-labelledby=\"" + (tab_ids.$join(" ")) + "\"";
            tabs['$<<'](self.$create_html_fragment(parent, "" + "<div" + (attrs) + ">"));
            $send(blocks, 'each', [], ($$5 = function(it){var self = $$5.$$s || this;

            
              
              if (it == null) {
                it = nil;
              };
              return tabs['$<<'](it);}, $$5.$$s = self, $$5.$$arity = 1, $$5));
            return tabs['$<<'](self.$create_html_fragment(parent, "</div>"));}, $$4.$$s = self, $$4.$$arity = 2, $$4));
          return tabs;
        }, $Block_process$1.$$arity = 3);
        self.$private();
        
        Opal.def(self, '$create_html_fragment', $Block_create_html_fragment$6 = function $$create_html_fragment(parent, html, attributes) {
          var self = this;

          
          
          if (attributes == null) {
            attributes = nil;
          };
          return self.$create_block(parent, "pass", html, attributes);
        }, $Block_create_html_fragment$6.$$arity = -3);
        
        Opal.def(self, '$generate_id', $Block_generate_id$7 = function $$generate_id(str, doc, base_id) {
          var $a, self = this, restore_idprefix = nil, attrs = nil, $writer = nil;

          
          
          if (base_id == null) {
            base_id = nil;
          };
          return (function() { try {
          
          if ($truthy(base_id)) {
            
            restore_idprefix = (attrs = doc.$attributes())['$[]']("idprefix");
            
            $writer = ["idprefix", "" + (base_id) + (($truthy($a = attrs['$[]']("idseparator")) ? $a : "_"))];
            $send(attrs, '[]=', Opal.to_a($writer));
            $writer[$rb_minus($writer["length"], 1)];;};
          return $$$($$$('::', 'Asciidoctor'), 'Section').$generate_id(str, doc);
          } finally {
            (function() {if ($truthy(base_id)) {
              if ($truthy(restore_idprefix)) {
                
                
                $writer = ["idprefix", restore_idprefix];
                $send(attrs, '[]=', Opal.to_a($writer));
                return $writer[$rb_minus($writer["length"], 1)];;
              } else {
                
                return attrs.$delete("idprefix");
              }
            } else {
              return nil
            }; return nil; })()
          }; })();
        }, $Block_generate_id$7.$$arity = -3);
        return (Opal.def(self, '$list_item_supports_id?', $Block_list_item_supports_id$ques$8 = function(doc) {
          var $$9, self = this, converter = nil, output = nil;

          if ($truthy((converter = doc.$converter())['$instance_variable_defined?']("@list_item_supports_id"))) {
            return converter.$instance_variable_get("@list_item_supports_id")
          } else {
            
            output = $send(self.$create_list(doc, "ulist"), 'tap', [], ($$9 = function(ul){var self = $$9.$$s || this, $$10;

            
              
              if (ul == null) {
                ul = nil;
              };
              return ul['$<<']($send(self.$create_list_item(ul), 'tap', [], ($$10 = function(li){var self = $$10.$$s || this, $writer = nil;

              
                
                if (li == null) {
                  li = nil;
                };
                $writer = ["name"];
                $send(li, 'id=', Opal.to_a($writer));
                return $writer[$rb_minus($writer["length"], 1)];}, $$10.$$s = self, $$10.$$arity = 1, $$10)));}, $$9.$$s = self, $$9.$$arity = 1, $$9)).$convert();
            return converter.$instance_variable_set("@list_item_supports_id", output['$include?'](" id=\"name\""));
          }
        }, $Block_list_item_supports_id$ques$8.$$arity = 1), nil) && 'list_item_supports_id?';
      })($nesting[0], $$$($$$($$$('::', 'Asciidoctor'), 'Extensions'), 'BlockProcessor'), $nesting)
    })($nesting[0], $nesting)
  })($nesting[0], $nesting)
})(Opal);

/* Generated by Opal 0.11.99.dev */
(function(Opal) {
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.const_get_qualified, $$ = Opal.const_get_relative, $breaker = Opal.breaker, $slice = Opal.slice, $module = Opal.module, $klass = Opal.klass, $truthy = Opal.truthy, $hash2 = Opal.hash2;

  Opal.add_stubs(['$==', '$absolute_path', '$use_dsl', '$at_location', '$join', '$attr', '$attr?', '$normalize_web_path', '$empty?', '$read_asset', '$read_contents', '$chomp']);
  return (function($base, $parent_nesting) {
    var self = $module($base, 'Asciidoctor');

    var $nesting = [self].concat($parent_nesting);

    (function($base, $parent_nesting) {
      var self = $module($base, 'Tabs');

      var $nesting = [self].concat($parent_nesting);

      (function($base, $parent_nesting) {
        var self = $module($base, 'Docinfo');

        var $nesting = [self].concat($parent_nesting);

        
        if ($$($nesting, 'RUBY_ENGINE')['$==']("opal")) {
          Opal.const_set($nesting[0], 'DATA_DIR', $$$('::', 'File').$absolute_path("../dist", __dirname))
        } else {
          nil
        };
        (function($base, $super, $parent_nesting) {
          var self = $klass($base, $super, 'Style');

          var $nesting = [self].concat($parent_nesting), $Style_process$1;

          
          self.$use_dsl();
          self.$at_location("head");
          Opal.const_set($nesting[0], 'DEFAULT_STYLESHEET_FILE', $$$('::', 'File').$join($$($nesting, 'DATA_DIR'), "css/tabs.css"));
          return (Opal.def(self, '$process', $Style_process$1 = function $$process(doc) {
            var self = this, path = nil, href = nil, styles = nil;

            
            if ($truthy((path = doc.$attr("tabs-stylesheet")))) {
            } else {
              return nil
            };
            if ($truthy(doc['$attr?']("linkcss"))) {
              
              href = doc.$normalize_web_path((function() {if ($truthy(path['$empty?']())) {
                return "asciidoctor-tabs.css"
              } else {
                return path
              }; return nil; })(), doc.$attr("stylesdir"));
              return "" + "<link rel=\"stylesheet\" href=\"" + (href) + "\"" + ((function() {if ($truthy(doc['$attr?']("htmlsyntax", "xml"))) {
                return "/"
              } else {
                return ""
              }; return nil; })()) + ">";
            } else if ($truthy((styles = (function() {if ($truthy(path['$empty?']())) {
              
              return doc.$read_asset($$($nesting, 'DEFAULT_STYLESHEET_FILE'));
            } else {
              
              return doc.$read_contents(path, $hash2(["start", "warn_on_failure", "label"], {"start": doc.$attr("stylesdir"), "warn_on_failure": true, "label": "tabs stylesheet"}));
            }; return nil; })()))) {
              return "" + "<style>\n" + (styles.$chomp()) + "\n</style>"
            } else {
              return nil
            };
          }, $Style_process$1.$$arity = 1), nil) && 'process';
        })($nesting[0], $$$($$$($$$('::', 'Asciidoctor'), 'Extensions'), 'DocinfoProcessor'), $nesting);
        (function($base, $super, $parent_nesting) {
          var self = $klass($base, $super, 'Behavior');

          var $nesting = [self].concat($parent_nesting), $Behavior_process$2;

          
          self.$use_dsl();
          self.$at_location("footer");
          Opal.const_set($nesting[0], 'JAVASCRIPT_FILE', $$$('::', 'File').$join($$($nesting, 'DATA_DIR'), "js/tabs.js"));
          return (Opal.def(self, '$process', $Behavior_process$2 = function $$process(doc) {
            var self = this, src = nil, script = nil;

            if ($truthy(doc['$attr?']("linkcss"))) {
              
              src = doc.$normalize_web_path("asciidoctor-tabs.js", doc.$attr("scriptsdir"));
              return "" + "<script src=\"" + (src) + "\"></script>";
            } else if ($truthy((script = doc.$read_asset($$($nesting, 'JAVASCRIPT_FILE'))))) {
              return "" + "<script>\n" + (script.$chomp()) + "\n</script>"
            } else {
              return nil
            }
          }, $Behavior_process$2.$$arity = 1), nil) && 'process';
        })($nesting[0], $$$($$$($$$('::', 'Asciidoctor'), 'Extensions'), 'DocinfoProcessor'), $nesting);
      })($nesting[0], $nesting)
    })($nesting[0], $nesting)
  })($nesting[0], $nesting)
})(Opal);

/* Generated by Opal 0.11.99.dev */
(function(Opal) {
  function $rb_minus(lhs, rhs) {
    return (typeof(lhs) === 'number' && typeof(rhs) === 'number') ? lhs - rhs : lhs['$-'](rhs);
  }
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.const_get_qualified, $$ = Opal.const_get_relative, $breaker = Opal.breaker, $slice = Opal.slice, $module = Opal.module, $send = Opal.send, $truthy = Opal.truthy, $hash2 = Opal.hash2;

  Opal.add_stubs(['$==', '$const_set', '$module_function', '$proc', '$block', '$embedded?', '$!', '$attr?', '$attribute_locked?', '$key?', '$transform_keys', '$[]', '$options', '$delete', '$set_attr', '$docinfo_processor', '$groups', '$key', '$group', '$[]=', '$-']);
  
  if ($$($nesting, 'RUBY_ENGINE')['$==']("opal")) {
  } else {
    nil
  };
  return (function($base, $parent_nesting) {
    var self = $module($base, 'Asciidoctor');

    var $nesting = [self].concat($parent_nesting);

    (function($base, $parent_nesting) {
      var self = $module($base, 'Tabs');

      var $nesting = [self].concat($parent_nesting);

      (function($base, $parent_nesting) {
        var self = $module($base, 'Extensions');

        var $nesting = [self].concat($parent_nesting), $Extensions_group$1, $Extensions_key$4, $Extensions_register$5, $Extensions_unregister$6;

        
        self.$const_set("Block", $$($nesting, 'Block'));
        self.$const_set("Docinfo", $$($nesting, 'Docinfo'));
        self.$module_function();
        
        Opal.def(self, '$group', $Extensions_group$1 = function $$group() {
          var $$2, self = this;

          return $send(self, 'proc', [], ($$2 = function(){var self = $$2.$$s || this, $a, $b, $$3, doc = nil;
            if (self.document == null) self.document = nil;

          
            self.$block($$($nesting, 'Block'), "tabs");
            if ($truthy(($truthy($a = (doc = self.document)['$embedded?']()) ? $a : doc['$attr?']("filetype", "html")['$!']()))) {
              return nil;};
            if ($truthy(($truthy($a = doc['$attribute_locked?']("tabs-stylesheet")) ? $a : $send(($truthy($b = doc.$options()['$[]']("attributes")) ? $b : $hash2([], {})), 'transform_keys', [], ($$3 = function(it){var self = $$3.$$s || this;

            
              
              if (it == null) {
                it = nil;
              };
              return it.$delete("@!");}, $$3.$$s = self, $$3.$$arity = 1, $$3))['$key?']("tabs-stylesheet")))) {
            } else {
              doc.$set_attr("tabs-stylesheet")
            };
            self.$docinfo_processor($$$($$($nesting, 'Docinfo'), 'Style'));
            self.$docinfo_processor($$$($$($nesting, 'Docinfo'), 'Behavior'));
            return nil;}, $$2.$$s = self, $$2.$$arity = 0, $$2))
        }, $Extensions_group$1.$$arity = 0);
        
        Opal.def(self, '$key', $Extensions_key$4 = function $$key() {
          var self = this;

          return "tabs"
        }, $Extensions_key$4.$$arity = 0);
        
        Opal.def(self, '$register', $Extensions_register$5 = function $$register(registry) {
          var $a, self = this, $logical_op_recvr_tmp_1 = nil, $writer = nil;

          
          
          if (registry == null) {
            registry = nil;
          };
          $logical_op_recvr_tmp_1 = ($truthy($a = registry) ? $a : $$$($$$('::', 'Asciidoctor'), 'Extensions')).$groups();
          return ($truthy($a = $logical_op_recvr_tmp_1['$[]'](self.$key())) ? $a : (($writer = [self.$key(), self.$group()]), $send($logical_op_recvr_tmp_1, '[]=', Opal.to_a($writer)), $writer[$rb_minus($writer["length"], 1)]));
        }, $Extensions_register$5.$$arity = -1);
        
        Opal.def(self, '$unregister', $Extensions_unregister$6 = function $$unregister(registry) {
          var $a, self = this;

          
          
          if (registry == null) {
            registry = nil;
          };
          ($truthy($a = registry) ? $a : $$$($$$('::', 'Asciidoctor'), 'Extensions')).$groups().$delete(self.$key());
          return nil;
        }, $Extensions_unregister$6.$$arity = -1);
      })($nesting[0], $nesting)
    })($nesting[0], $nesting)
  })($nesting[0], $nesting);
})(Opal);
