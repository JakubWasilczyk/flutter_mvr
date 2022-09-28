library flutter_mvr_generator.builder;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator/model_generator.dart';

Builder modelBuilder(BuilderOptions options) => PartBuilder(
      [ModelGenerator()],
      '.base.dart',
      options: const BuilderOptions({
        "build_extensions": {
          "{{dir}}/{{file}}.dart": "{{dir}}/base/{{file}}.base.dart",
        },
      }),
    );
