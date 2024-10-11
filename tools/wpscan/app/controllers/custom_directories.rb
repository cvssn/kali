# frozen_string_literal: true

module WPScan
    module Controller
        # controlador para garantir que os diretórios wp-content e
        # wp-plugins sejam encontrados
        class CustomDirectories < CMSScanner::Controller::Base
            def cli_options
                [
                    OptString.new(['--wp-content-dir DIR',
                                'o diretório wp-content, se personalizado ou não detectado, como "wp-content"']),
                    OptString.new(['--wp-plugins-dir DIR',
                                'o diretório de plugins, se personalizado ou não detectado, como "wp-content/plugins"'])
                ]
            end
    
            def before_scan
                target.content_dir = ParsedCli.wp_content_dir if ParsedCli.wp_content_dir
                target.plugins_dir = ParsedCli.wp_plugins_dir if ParsedCli.wp_plugins_dir
        
                raise Error::WpContentDirNotDetected unless target.content_dir
            end
        end
    end
end