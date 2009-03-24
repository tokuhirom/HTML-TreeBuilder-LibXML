package HTML::TreeBuilder::LibXML;
use strict;
use warnings;
our $VERSION = '0.01';
use Carp ();

BEGIN {
    my @treebuilder_methods =
      qw(ABORT DEBUG OK PRUNE PRUNE_SOFTLY PRUNE_UP Version address all_attr all_attr_names all_external_attr all_external_attr_names as_HTML as_Lisp_form as_XML as_text as_text_trimmed as_trimmed_text attr attr_encoded attr_get_i backquote boolean_attribute_value bootstrap case_sensitive clone clone_list closing_plaintext comment content content_array_ref content_list content_refs_list declaration delete delete_content delete_ignorable_whitespace deobjectify_text depth descendants descendents destroy destroy_content detach detach_content disembowel done dump elementify empty_element_tags end endtag endtag_XML eof extract_links find find_by_attribute find_by_tag_name format guts handler has_insane_linkage id idf ignore_elements ignore_ignorable_whitespace ignore_tags ignore_text ignore_unknown implicit implicit_body_p_tag implicit_tags init insert_element is_empty is_inside left lineage lineage_tag_names look_down look_up marked_sections netscape_buggy_comment new new_from_content new_from_file new_from_lol no_space_compacting normalize_content number_lists objectify_text p_strict parent parse parse_content parse_file pindex pos postinsert preinsert process push_content replace_with replace_with_content report_tags right root same_as simplify_pres splice_content start starttag starttag_XML store_comments store_declarations store_pis strict_comment strict_end strict_names stunt stunted tag tagname_map text tighten_up traverse unbroken_text unshift_content utf8_mode warn warning xml_mode xml_pic);

    no strict 'refs';
    for my $meth (@treebuilder_methods) {
        *{__PACKAGE__ . "::$meth"} = \&_not_implemented_yet;
    }
}

sub _not_implemented_yet {
    Carp::croak "this method is not implemented yet";
}

1;
__END__

=head1 NAME

HTML::TreeBuilder::LibXML -

=head1 SYNOPSIS

  use HTML::TreeBuilder::LibXML;

=head1 DESCRIPTION

HTML::TreeBuilder::LibXML is drop-in-replacement version of HTML::TreeBuilder.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom  slkjfd gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
