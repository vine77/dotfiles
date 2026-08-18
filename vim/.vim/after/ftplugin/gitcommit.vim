" Commit-message-only settings. setlocal keeps every one of these scoped to
" this buffer — nothing here leaks into normal editing.
"
" Vim's bundled gitcommit ftplugin already sets textwidth=72, which wraps the
" body but will happily wrap an overlong *subject* onto line 2 and quietly
" break the message structure. The rulers mark both walls: 50 for the subject,
" 72 for the body.
setlocal colorcolumn=51,73
setlocal spell spelllang=en_us
