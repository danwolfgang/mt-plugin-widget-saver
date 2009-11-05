package WidgetSaver::Plugin;

use strict;

sub template_source {
    my ($cb, $app, $tmpl) = @_;
    my $orig = qq{<label for="backup"><__trans phrase="Make backups of existing templates first"></label>
        </div>}; # Note the two tab indent here.

    my $add = <<END_TMPL;
<div>
    <input type="checkbox" id="widget_set_saver" name="widget_set_saver" value="1" checked="checked" />
    <label for="widgetsetsaver">Save any existing Widget Sets in this blog.</label>
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

    my $count = 0; # To grab the current array item index.
    foreach my $tmpl (@$templates) {
        if ($tmpl->{'type'} eq 'widgetset') {
            # Save Widget Sets?
            if ( $app->param('widget_set_saver') ) {
                # Try to count a Widget Set in this blog with the same identifier.
                use MT::Template;
                my $installed = MT::Template->count( { blog_id    => $app->blog->id,
                                                       type       => 'widgetset',
                                                       identifier => $tmpl->{'identifier'}, } );
                # If a Widget Set by this name was found, remove the template from the
                # array of those templates to be installed.
                if ($installed) {
                    # Delete the Widget Set so it doesn't overwrite our existing Widget Set!
                    splice(@$templates, $count, 1);
                }
            }
        }
        
        if ($tmpl->{'type'} eq 'widget') {
            # Save Widgets?
            if ( $app->param('widget_saver') ) { 
                # Try to count a Widget in this blog with the same identifier.
                use MT::Template;
                my $installed = MT::Template->count( { blog_id    => $app->blog->id,
                                                       type       => 'widget',
                                                       identifier => $tmpl->{'identifier'}, } );
                # If a Widget by this name was found, remove the template from the
                # array of those templates to be installed.
                if ($installed) {
                    # Delete the Widget so it doesn't overwrite our existing Widget!
                    splice(@$templates, $count, 1);
                }
            }
        }
        
        $count++; # Increment the count to maintain the correct index.
    }
}

1;

__END__
