module sui_file_explorer::file_system {
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self, String};
    use sui::table::{Self, Table};
    use sui::event;
    use std::option::{Self, Option};
    use sui::package;
    use sui::display;
    use std::vector;

    // One-time witness for package publishing
    struct FILE_SYSTEM has drop {}

    // Capability for admin operations
    struct AdminCap has key, store {
        id: UID
    }

    // Main FileSystem object that stores the root reference
    struct FileSystem has key {
        id: UID,
        root_id: ID,
        version: u64
    }

    // Represents a directory/folder
    struct Folder has key, store {
        id: UID,
        name: String,
        parent_id: Option<ID>,
        entries: Table<String, Entry>,
        entry_names: vector<String>  // Keep track of entry names for iteration
    }

    // Represents a file
    struct File has key, store {
        id: UID,
        name: String,
        parent_id: ID,
        walrus_object_id: ID,  // The Sui object ID
        walrus_blob_id: String,  // The actual Walrus blob ID string
        content_type: String,
        size: u64,
        created_at: u64,
    }

    // Entry type to store in folder's table
    struct Entry has store, copy {
        id: ID,
        entry_type: u8  // 0 for folder, 1 for file
    }

    // Events
    struct FolderCreated has copy, drop {
        folder_id: ID,
        name: String,
        parent_id: Option<ID>
    }

    struct FileCreated has copy, drop {
        file_id: ID,
        name: String,
        parent_id: ID,
        blob_id: ID
    }

    // Error codes
    const E_NAME_TAKEN: u64 = 2;

    // Entry type constants
    const FOLDER_TYPE: u8 = 0;
    const FILE_TYPE: u8 = 1;

    // fun init(witness: FILE_SYSTEM, ctx: &mut TxContext) {
    //     let publisher = package::claim(witness, ctx);
        
    //     // Create and share the admin capability
    //     transfer::transfer(AdminCap {
    //         id: object::new(ctx)
    //     }, tx_context::sender(ctx));

    //     // Create root folder
    //     let root_folder = Folder {
    //         id: object::new(ctx),
    //         name: string::utf8(b"root"),
    //         parent_id: option::none(),
    //         entries: table::new(ctx),
    //         entry_names: vector::empty()
    //     };
    //     let root_id = object::id(&root_folder);
        
    //     // Share root folder
    //     transfer::share_object(root_folder);

    //     // Create and share filesystem object
    //     let file_system = FileSystem {
    //         id: object::new(ctx),
    //         root_id,
    //         version: 1
    //     };
    //     transfer::share_object(file_system);

    //     // Setup display
    //     let display = display::new_with_fields<FileSystem>(
    //         &publisher,
    //         vector[
    //             string::utf8(b"name"),
    //             string::utf8(b"description"),
    //             string::utf8(b"version"),
    //         ],
    //         vector[
    //             string::utf8(b"Walrus File System"),
    //             string::utf8(b"Decentralized file system for Walrus blobs"),
    //             string::utf8(b"1.0.0"),
    //         ],
    //         ctx
    //     );
    //     display::update_version(&mut display);
    //     transfer::public_transfer(publisher, tx_context::sender(ctx));
    //     transfer::public_transfer(display, tx_context::sender(ctx));
    // }
    fun init(witness: FILE_SYSTEM, ctx: &mut TxContext) {
        let publisher = package::claim(witness, ctx);
        
        // Create and share the admin capability
        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));

        // Create root folder
        let root_folder = Folder {
            id: object::new(ctx),
            name: string::utf8(b"root"),
            parent_id: option::none(),
            entries: table::new(ctx),
            entry_names: vector::empty()
        };
        let root_id = object::id(&root_folder);
        
        // Share root folder
        transfer::share_object(root_folder);

        // Create and share filesystem object
        let file_system = FileSystem {
            id: object::new(ctx),
            root_id,
            version: 1
        };
        transfer::share_object(file_system);

        // Setup filesystem display
        let fs_display = display::new_with_fields<FileSystem>(
            &publisher,
            vector[
                string::utf8(b"name"),
                string::utf8(b"description"),
                string::utf8(b"version"),
            ],
            vector[
                string::utf8(b"Walrus File System"),
                string::utf8(b"Decentralized file system for Walrus blobs"),
                string::utf8(b"1.0.0"),
            ],
            ctx
        );
        display::update_version(&mut fs_display);

        // Setup file display
        let file_display = display::new_with_fields<File>(
            &publisher,
            vector[
                string::utf8(b"name"),
                string::utf8(b"description"),
                string::utf8(b"content_url"),
                string::utf8(b"thumbnail"),
                string::utf8(b"link"),
            ],
            vector[
                string::utf8(b"{name}"),
                string::utf8(b"Walrus file stored at {blob_id}"),
                string::utf8(b"https://walrus.testnet.sui.io/api/v1/object/{blob_id}"),
                string::utf8(b"https://walrus.testnet.sui.io/api/v1/preview/{blob_id}"),
                string::utf8(b"https://walrus.testnet.sui.io/blob/{blob_id}"),
            ],
            ctx
        );
        display::update_version(&mut file_display);

        // Transfer publisher and displays
        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(fs_display, tx_context::sender(ctx));
        transfer::public_transfer(file_display, tx_context::sender(ctx));
    }

    // Create a new folder
    public entry fun create_folder(
        _admin: &AdminCap,
        parent: &mut Folder,
        name: vector<u8>,
        ctx: &mut TxContext
    ) {
        let folder_name = string::utf8(name);
        assert!(!table::contains(&parent.entries, folder_name), E_NAME_TAKEN);

        let new_folder = Folder {
            id: object::new(ctx),
            name: folder_name,
            parent_id: option::some(object::id(parent)),
            entries: table::new(ctx),
            entry_names: vector::empty()
        };

        let folder_id = object::id(&new_folder);
        
        table::add(&mut parent.entries, *&folder_name, Entry {
            id: folder_id,
            entry_type: FOLDER_TYPE
        });
        vector::push_back(&mut parent.entry_names, folder_name);

        event::emit(FolderCreated {
            folder_id,
            name: folder_name,
            parent_id: option::some(object::id(parent))
        });

        transfer::share_object(new_folder);
    }

    // Create a new file
    public entry fun create_file(
    _admin: &AdminCap,
    parent: &mut Folder,
    name: vector<u8>,
    walrus_object_id: vector<u8>,
    walrus_blob_id: vector<u8>,
    content_type: vector<u8>,
    size: u64,
    ctx: &mut TxContext
) {
    let file_name = string::utf8(name);
    assert!(!table::contains(&parent.entries, file_name), E_NAME_TAKEN);

    let object_id = object::id_from_bytes(walrus_object_id);
    let blob_id = string::utf8(walrus_blob_id); // Store the blob ID as a string

    let new_file = File {
        id: object::new(ctx),
        name: file_name,
        parent_id: object::id(parent),
        walrus_object_id: object_id,
        walrus_blob_id: blob_id,
        content_type: string::utf8(content_type),
        size,
        created_at: tx_context::epoch(ctx)
    };

    let file_id = object::id(&new_file);
    
    table::add(&mut parent.entries, *&file_name, Entry {
        id: file_id,
        entry_type: FILE_TYPE
    });
    vector::push_back(&mut parent.entry_names, file_name);

    event::emit(FileCreated {
        file_id,
        name: file_name,
        parent_id: object::id(parent),
        blob_id: object_id  // Using walrus_object_id here
    });

    transfer::share_object(new_file);
}

    // Get folder contents
    public fun get_folder_contents(folder: &Folder): (vector<String>, vector<ID>, vector<u8>) {
        let names = vector::empty<String>();
        let ids = vector::empty<ID>();
        let types = vector::empty<u8>();
        
        let i = 0;
        let len = vector::length(&folder.entry_names);
        
        while (i < len) {
            let name = *vector::borrow(&folder.entry_names, i);
            let entry = table::borrow(&folder.entries, name);
            
            vector::push_back(&mut names, name);
            vector::push_back(&mut ids, entry.id);
            vector::push_back(&mut types, entry.entry_type);
            
            i = i + 1;
        };
        
        (names, ids, types)
    }

    // Get file details
    public fun get_file_details(file: &File): (String, ID, String, u64) {
        (file.name, file.walrus_object_id, file.content_type, file.size)
    }

    // Get folder name
    public fun get_folder_name(folder: &Folder): String {
        folder.name
    }

    // Get parent ID
    public fun get_parent_id(folder: &Folder): Option<ID> {
        folder.parent_id
    }

    // Check if entry exists
    public fun has_entry(folder: &Folder, name: &String): bool {
        table::contains(&folder.entries, *name)
    }
}