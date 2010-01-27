package WidgetSaver::Plugin;

use strict;

sub template_source {
    my ($cb, $app, $tmpl) = @_;
    my $orig = qq{<label for="backup"><__trans phrase="Make backups of existing templates first"></label>
        </div>}; # Note the two tab indent here.

    my $add = <<END_TMPL;
<div>
    <input type="checkbox" id="widget_set_saver" name="widget_set_saver" value="1" checked="checked" />
    <label for="widget_set_saver">Save any existing Widget Sets in this blog.</label>
</div>
<div>
    <input type="checkbox" id="widget_saver" name="widget_saver" value="1" checked="checked" />
    <label for="widget_saver">Save any existing Widgets in this blog.</label>
</div>
END_TMPL
    $$tmpl =~ s/$orig/$orig$add/;
}

sub template_filter {
    my ($cb, $templates) = @_;
    my $app = MT->instance;
    my $blog_id = $app->blog ? $app->blog->id : '0'; # '0' for system-level widgets/widget sets

    my $index = 0; # To grab the current array item index.
    my $tmpl_count = scalar @$templates;
MT->log("Template count: $tmpl_count");
    while ($index <= $tmpl_count) {
        my $tmpl = @$templates[$index];
        MT->log('Template: '.$tmpl->{'identifier'}.', Type: '.$tmpl->{'type'}.", Blog: $blog_id, Index: $index");
        if ($tmpl->{'type'} eq 'widgetset') {
            # Save Widget Sets?
            if ( $app->param('widget_set_saver') ) {
                # Try to count a Widget Set in this blog with the same identifier.
                use MT::Template;
                my $installed = MT::Template->count( { blog_id    => $blog_id,
                                                       type       => 'widgetset',
                                                       identifier => $tmpl->{'identifier'}, } );
                # If a Widget Set by this name was found, remove the template from the
                # array of those templates to be installed.
                if ($installed) {
                    # Delete the Widget Set so it doesn't overwrite our existing Widget Set!
                    splice(@$templates, $index, 1);
                    next;
                }
            }
        }
        elsif ($tmpl->{'type'} eq 'widget') {
            # Save Widgets?
            if ( $app->param('widget_saver') ) { 
                # Try to count a Widget in this blog with the same identifier.
                use MT::Template;
                my $installed = MT::Template->count( { blog_id    => $blog_id,
                                                       type       => 'widget',
                                                       identifier => $tmpl->{'identifier'}, } );
                # If a Widget by this name was found, remove the template from the
                # array of those templates to be installed.
                if ($installed) {
                    MT->log($tmpl->{'identifier'}." is installed already. Don't overwrite it!");
                    # Delete the Widget so it doesn't overwrite our existing Widget!
                    splice(@$templates, $index, 1);
                    next;
                }
            }
        }
        $index++;
    }
}

1;

__END__
