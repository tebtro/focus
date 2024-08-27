Vim_Mode :: enum {
    DEFAULT;  // Used when not the active editor, or when in other widgets.
    NORMAL;
    INSERT;
    VISUAL;
    //
    COUNT;
}

vim_enter_mode :: (editor: *Editor, mode: Vim_Mode) {
    log("Vim enter mode: %", mode);
    editor.vim_mode = mode;
}

vim_can_type_char :: (editor: *Editor) -> bool {
    if editor.vim_mode == {
        case .DEFAULT; #through;
        case .INSERT;
            return true;
    }

    return false;
}

vim_move_to_visual_line_start :: (editor: *Editor, buffer: *Buffer) {
    for * cursor : editor.cursors {
        line := offset_to_real_line(buffer, cursor.pos);
        start, end := get_real_line_start_offset(buffer, line), get_real_line_end_offset(buffer, line);

        text_start_col: s32 = 0;
        i := start;
        while i < end {
            byte := buffer.bytes[i];
            if byte != #char " " && byte != #char "\t" break;
            text_start_col += 1;
            i += 1 + trailingBytesForUTF8[byte];
        }
        if cursor.pos > i || cursor.pos == start then cursor.pos = i; else cursor.pos = start;
        cursor.col_wanted = -1;
    }

    editor.cursor_moved = .unimportant;
}

vim_move_to_visual_line_end :: (editor: *Editor, buffer: *Buffer) {
    for * cursor : editor.cursors {
        line := offset_to_real_line(buffer, cursor.pos);
        cursor.pos = get_real_line_end_offset(buffer, line);
        cursor.col_wanted = -1;
    }

    editor.cursor_moved = .unimportant;
}

vim_move_to_textual_line_start :: (editor: *Editor, buffer: *Buffer) {
    for * cursor : editor.cursors {
        line := offset_to_real_line(buffer, cursor.pos);
        cursor.pos = get_real_line_start_offset(buffer, line);
        cursor.col_wanted = -1;
    }

    editor.cursor_moved = .unimportant;
}

vim_move_to_textual_line_end :: (editor: *Editor, buffer: *Buffer) {
    // @todo
    vim_move_to_visual_line_end(editor, buffer);
}

vim_move_cursors_by_half_page :: (editor: *Editor, buffer: Buffer, dir: enum { up; down; }) {
    page_size := cast(s32) ((window_height / line_height) / 2);
    offset := ifx dir == .up then -page_size else page_size;

    for * cursor : editor.cursors {
        line := offset_to_line(editor, buffer, cursor.pos);
        line += offset;
        cursor.pos = coords_to_offset(editor, buffer, Coords.{ line = line, col = cursor.col_wanted });
    }

    if dir == .up  editor.cursor_moved = .moved_up;
    else           editor.cursor_moved = .moved_down;
}

vim_move_up_half_page :: (editor: *Editor, buffer: *Buffer) {
    vim_move_cursors_by_half_page(editor, buffer, .up);
}

vim_move_down_half_page :: (editor: *Editor, buffer: *Buffer) {
    vim_move_cursors_by_half_page(editor, buffer, .down);
}

vim_move_right_word_start :: (editor: *Editor, buffer: *Buffer) {}
vim_move_right_word_end :: (editor: *Editor, buffer: *Buffer) {}
vim_move_left_word_start :: (editor: *Editor, buffer: *Buffer) {}
vim_move_left_word_end :: (editor: *Editor, buffer: *Buffer) {}
vim_move_right_token_start :: (editor: *Editor, buffer: *Buffer) {}
vim_move_right_token_end :: (editor: *Editor, buffer: *Buffer) {}
vim_move_left_token_start :: (editor: *Editor, buffer: *Buffer) {}
vim_move_left_token_end :: (editor: *Editor, buffer: *Buffer) {}
vim_move_right_one_after_whitespace :: (editor: *Editor, buffer: *Buffer) {}
vim_move_right_one_before_whitespace :: (editor: *Editor, buffer: *Buffer) {}
vim_move_left_one_after_whitespace :: (editor: *Editor, buffer: *Buffer) {}
vim_move_left_one_before_whitespace :: (editor: *Editor, buffer: *Buffer) {}
