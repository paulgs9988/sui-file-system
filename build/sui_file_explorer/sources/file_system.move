// module sui_file_explorer::file_system {
//     use sui::object::{Self, ID, UID};
//     use sui::transfer;
//     use sui::tx_context::{Self, TxContext};
//     use sui::dynamic_object_field as dof;
//     use std::string::{Self, String};
//     use sui::vec_map::{Self, VecMap};
//     use sui::event;

//     // Capability for administrative actions
//     struct AdminCap has key, store {
//         id: UID
//     }

//     // Root folder struct
//     struct RootFolder has key, store {
//         id: UID,
//         child_ids: VecMap<ID, bool>
//     }

//     // Regular folder struct
//     struct Folder has key, store {
//         id: UID,
//         name: String,
//         child_ids: VecMap<ID, bool>
//     }

//     // File struct
//     struct File has key, store {
//         id: UID,
//         name: String,
//         ipfs_hash: String
//     }

//     // Events
//     struct FolderCreated has copy, drop {
//         folder_id: ID,
//         name: String,
//         parent_id: ID
//     }

//     struct FileCreated has copy, drop {
//         file_id: ID,
//         name: String,
//         parent_id: ID
//     }

//     // Error codes
//     const E_NOT_ADMIN: u64 = 0;
//     const E_INVALID_PARENT: u64 = 1;

//     // Create AdminCap and RootFolder on module init
//     fun init(ctx: &mut TxContext) {
//         let sender = tx_context::sender(ctx);
        
//         // Create and transfer AdminCap
//         transfer::transfer(AdminCap {
//             id: object::new(ctx)
//         }, sender);

//         // Create and transfer RootFolder
//         transfer::share_object(RootFolder {
//             id: object::new(ctx),
//             child_ids: vec_map::empty()
//         });
//     }

//     // Create a new folder in the root
//     public entry fun create_folder_in_root(
//         _admin: &AdminCap,
//         root: &mut RootFolder,
//         name: vector<u8>,
//         ctx: &mut TxContext
//     ) {
//         let folder = Folder {
//             id: object::new(ctx),
//             name: string::utf8(name),
//             child_ids: vec_map::empty()
//         };

//         let folder_id = object::id(&folder);
//         vec_map::insert(&mut root.child_ids, folder_id, true);
        
//         event::emit(FolderCreated {
//             folder_id,
//             name: string::utf8(name),
//             parent_id: object::id(root)
//         });

//         dof::add(&mut root.id, folder_id, folder);
//     }

//     public entry fun create_folder_in_folder(
//     _admin: &AdminCap,
//     root: &mut RootFolder,  // Add root folder parameter
//     parent_id: vector<u8>,  // Pass parent folder ID as bytes
//     name: vector<u8>,
//     ctx: &mut TxContext
// ) {
//     let parent_folder = dof::borrow_mut<ID, Folder>(
//         &mut root.id,
//         object::id_from_bytes(parent_id)
//     );

//     let folder = Folder {
//         id: object::new(ctx),
//         name: string::utf8(name),
//         child_ids: vec_map::empty()
//     };

//     let folder_id = object::id(&folder);
//     vec_map::insert(&mut parent_folder.child_ids, folder_id, true);
//     dof::add(&mut parent_folder.id, folder_id, folder);
// }

//     // Create a new file in root
//     public entry fun create_file_in_root(
//         _admin: &AdminCap,
//         root: &mut RootFolder,
//         name: vector<u8>,
//         ipfs_hash: vector<u8>,
//         ctx: &mut TxContext
//     ) {
//         let file = File {
//             id: object::new(ctx),
//             name: string::utf8(name),
//             ipfs_hash: string::utf8(ipfs_hash)
//         };

//         let file_id = object::id(&file);
//         vec_map::insert(&mut root.child_ids, file_id, true);
        
//         event::emit(FileCreated {
//             file_id,
//             name: string::utf8(name),
//             parent_id: object::id(root)
//         });

//         dof::add(&mut root.id, file_id, file);
//     }

//     // Create a new file in a folder
//     public entry fun create_file_in_folder(
//     _admin: &AdminCap,
//     root: &mut RootFolder,  // Add root folder parameter
//     parent_id: vector<u8>,  // Pass parent folder ID as bytes
//     name: vector<u8>,
//     ipfs_hash: vector<u8>,
//     ctx: &mut TxContext
// ) {
//     let parent_folder = dof::borrow_mut<ID, Folder>(
//         &mut root.id,
//         object::id_from_bytes(parent_id)
//     );

//     let file = File {
//         id: object::new(ctx),
//         name: string::utf8(name),
//         ipfs_hash: string::utf8(ipfs_hash)
//     };

//     let file_id = object::id(&file);
//     vec_map::insert(&mut parent_folder.child_ids, file_id, true);
//     dof::add(&mut parent_folder.id, file_id, file);

//     event::emit(FileCreated {
//         file_id,
//         name: string::utf8(name),
//         parent_id: object::id(parent_folder)
//     });
// }

//     // Get contents of root folder
//     public fun get_root_contents(root: &RootFolder): &VecMap<ID, bool> {
//         &root.child_ids
//     }

//     // Get contents of regular folder
//     public fun get_folder_contents(folder: &Folder): &VecMap<ID, bool> {
//         &folder.child_ids
//     }

//     // Get file details
//     public fun get_file_details(file: &File): (String, String) {
//         (file.name, file.ipfs_hash)
//     }

//     // Get folder name
//     public fun get_folder_name(folder: &Folder): String {
//         folder.name
//     }
// }

//ata least 3 levels:
// module sui_file_explorer::file_system {
//     use sui::object::{Self, ID, UID};
//     use sui::transfer;
//     use sui::tx_context::{Self, TxContext};
//     use sui::dynamic_object_field as dof;
//     use std::string::{Self, String};
//     use sui::vec_map::{Self, VecMap};
//     use sui::event;
//     use std::vector;

//     struct AdminCap has key, store {
//         id: UID
//     }

//     struct RootFolder has key, store {
//         id: UID,
//         child_ids: VecMap<ID, bool>
//     }

//     struct Folder has key, store {
//         id: UID,
//         name: String,
//         parent_id: ID,
//         child_ids: VecMap<ID, bool>
//     }

//     struct File has key, store {
//         id: UID,
//         name: String,
//         parent_id: ID,
//         ipfs_hash: String
//     }

//     struct FolderCreated has copy, drop {
//         folder_id: ID,
//         name: String,
//         parent_id: ID
//     }

//     struct FileCreated has copy, drop {
//         file_id: ID,
//         name: String,
//         parent_id: ID
//     }

//     const E_FOLDER_NOT_FOUND: u64 = 2;

//     fun init(ctx: &mut TxContext) {
//         let sender = tx_context::sender(ctx);
        
//         transfer::transfer(AdminCap {
//             id: object::new(ctx)
//         }, sender);

//         transfer::share_object(RootFolder {
//             id: object::new(ctx),
//             child_ids: vec_map::empty()
//         });
//     }

//     fun find_mut(root: &mut RootFolder, target_id: ID): &mut UID {
//         if (dof::exists_<ID>(&root.id, target_id)) {
//             return &mut root.id
//         };
        
//         // Check immediate children
//         let children = vec_map::keys(&root.child_ids);
//         let i = 0;
//         while (i < vector::length(&children)) {
//             let child_id = *vector::borrow(&children, i);
            
//             // If this child exists as a folder
//             if (dof::exists_<ID>(&root.id, child_id)) {
//                 let child = dof::borrow_mut<ID, Folder>(&mut root.id, child_id);
                
//                 // If this is the target
//                 if (object::id(child) == target_id) {
//                     return &mut child.id
//                 };
                
//                 // If the target might be in this child's children
//                 if (vec_map::contains(&child.child_ids, &target_id)) {
//                     return &mut child.id
//                 };
//             };
//             i = i + 1;
//         };
        
//         abort E_FOLDER_NOT_FOUND
//     }

//     public entry fun create_folder_in_root(
//         _admin: &AdminCap,
//         root: &mut RootFolder,
//         name: vector<u8>,
//         ctx: &mut TxContext
//     ) {
//         let root_id = object::id(root);
//         let folder = Folder {
//             id: object::new(ctx),
//             name: string::utf8(name),
//             parent_id: root_id,
//             child_ids: vec_map::empty()
//         };

//         let folder_id = object::id(&folder);
//         vec_map::insert(&mut root.child_ids, folder_id, true);
        
//         event::emit(FolderCreated {
//             folder_id,
//             name: string::utf8(name),
//             parent_id: root_id
//         });

//         dof::add(&mut root.id, folder_id, folder);
//     }

//     public entry fun create_folder_in_folder(
//         _admin: &AdminCap,
//         root: &mut RootFolder,
//         parent_id: vector<u8>,
//         name: vector<u8>,
//         ctx: &mut TxContext
//     ) {
//         let parent_folder_id = object::id_from_bytes(parent_id);
//         let parent_container = find_mut(root, parent_folder_id);
//         let parent = dof::borrow_mut<ID, Folder>(parent_container, parent_folder_id);

//         let folder = Folder {
//             id: object::new(ctx),
//             name: string::utf8(name),
//             parent_id: parent_folder_id,
//             child_ids: vec_map::empty()
//         };

//         let folder_id = object::id(&folder);
//         vec_map::insert(&mut parent.child_ids, folder_id, true);
//         dof::add(&mut parent.id, folder_id, folder);

//         event::emit(FolderCreated {
//             folder_id,
//             name: string::utf8(name),
//             parent_id: parent_folder_id
//         });
//     }

//     public entry fun create_file_in_root(
//         _admin: &AdminCap,
//         root: &mut RootFolder,
//         name: vector<u8>,
//         ipfs_hash: vector<u8>,
//         ctx: &mut TxContext
//     ) {
//         let root_id = object::id(root);
//         let file = File {
//             id: object::new(ctx),
//             name: string::utf8(name),
//             parent_id: root_id,
//             ipfs_hash: string::utf8(ipfs_hash)
//         };

//         let file_id = object::id(&file);
//         vec_map::insert(&mut root.child_ids, file_id, true);
        
//         event::emit(FileCreated {
//             file_id,
//             name: string::utf8(name),
//             parent_id: root_id
//         });

//         dof::add(&mut root.id, file_id, file);
//     }

//     public entry fun create_file_in_folder(
//         _admin: &AdminCap,
//         root: &mut RootFolder,
//         parent_id: vector<u8>,
//         name: vector<u8>,
//         ipfs_hash: vector<u8>,
//         ctx: &mut TxContext
//     ) {
//         let parent_folder_id = object::id_from_bytes(parent_id);
//         let parent_container = find_mut(root, parent_folder_id);
//         let parent = dof::borrow_mut<ID, Folder>(parent_container, parent_folder_id);

//         let file = File {
//             id: object::new(ctx),
//             name: string::utf8(name),
//             parent_id: parent_folder_id,
//             ipfs_hash: string::utf8(ipfs_hash)
//         };

//         let file_id = object::id(&file);
//         vec_map::insert(&mut parent.child_ids, file_id, true);
//         dof::add(&mut parent.id, file_id, file);

//         event::emit(FileCreated {
//             file_id,
//             name: string::utf8(name),
//             parent_id: parent_folder_id
//         });
//     }

//     public fun get_root_contents(root: &RootFolder): &VecMap<ID, bool> {
//         &root.child_ids
//     }

//     public fun get_folder_contents(folder: &Folder): &VecMap<ID, bool> {
//         &folder.child_ids
//     }

//     public fun get_file_details(file: &File): (String, String) {
//         (file.name, file.ipfs_hash)
//     }

//     public fun get_folder_name(folder: &Folder): String {
//         folder.name
//     }

//     public fun get_parent_id(folder: &Folder): ID {
//         folder.parent_id
//     }
// }
//ABOVE IS PREVIOUS IMPLEMENTATION, BELOW IS WIP TREE IMPLEMENTATION FAILING BEYOND 3 LEVELS.
module sui_file_explorer::file_system {
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_object_field as dof;
    use std::string::{Self, String};
    use sui::vec_map::{Self, VecMap};
    use sui::event;
    use std::vector;
    use std::option::{Self, Option};

    struct AdminCap has key, store {
        id: UID
    }

    struct RootFolder has key, store {
        id: UID,
        child_ids: VecMap<ID, bool>
    }

    struct Folder has key, store {
        id: UID,
        name: String,
        parent_id: ID,
        child_ids: VecMap<ID, bool>
    }

    struct File has key, store {
        id: UID,
        name: String,
        parent_id: ID,
        ipfs_hash: String
    }

    struct FolderCreated has copy, drop {
        folder_id: ID,
        name: String,
        parent_id: ID
    }

    struct FileCreated has copy, drop {
        file_id: ID,
        name: String,
        parent_id: ID
    }

    const E_FOLDER_NOT_FOUND: u64 = 2;

    fun init(ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        
        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, sender);

        transfer::share_object(RootFolder {
            id: object::new(ctx),
            child_ids: vec_map::empty()
        });
    }

    fun find_mut(root: &mut RootFolder, folder_id: ID): &mut UID {
        if (dof::exists_(&root.id, folder_id)) {
            return &mut dof::borrow_mut<ID, Folder>(&mut root.id, folder_id).id
        };

        let root_children = vec_map::keys(&root.child_ids);
        let i = 0;
        while (i < vector::length(&root_children)) {
            let child_id = *vector::borrow(&root_children, i);
            if (child_id == folder_id) {
                return &mut dof::borrow_mut<ID, Folder>(&mut root.id, child_id).id
            };
            i = i + 1;
        };
        
        abort E_FOLDER_NOT_FOUND
    }

    fun find_mut_recursive(parent: &mut Folder, folder_id: ID): Option<ID> {
        let child_ids = vec_map::keys(&parent.child_ids);
        let i = 0;
        
        while (i < vector::length(&child_ids)) {
            let child_id = *vector::borrow(&child_ids, i);
            if (dof::exists_(&parent.id, child_id)) {
                let child = dof::borrow_mut<ID, Folder>(&mut parent.id, child_id);
                if (object::id(child) == folder_id) {
                    return option::some(child_id)
                };
                
                if (!vec_map::is_empty(&child.child_ids)) {
                    let grandchild_result = find_mut_recursive(child, folder_id);
                    if (option::is_some(&grandchild_result)) {
                        return grandchild_result
                    }
                }
            };
            
            i = i + 1;
        };
        
        option::none()
    }

    public entry fun create_folder_in_root(
        _admin: &AdminCap,
        root: &mut RootFolder,
        name: vector<u8>,
        ctx: &mut TxContext
    ) {
        let root_id = object::id(root);
        let folder = Folder {
            id: object::new(ctx),
            name: string::utf8(name),
            parent_id: root_id,
            child_ids: vec_map::empty()
        };

        let folder_id = object::id(&folder);
        vec_map::insert(&mut root.child_ids, folder_id, true);
        
        event::emit(FolderCreated {
            folder_id,
            name: string::utf8(name),
            parent_id: root_id
        });

        dof::add(&mut root.id, folder_id, folder);
    }

    public entry fun create_folder_in_folder(
        _admin: &AdminCap,
        root: &mut RootFolder,
        parent_id: vector<u8>,
        name: vector<u8>,
        ctx: &mut TxContext
    ) {
        let parent_folder_id = object::id_from_bytes(parent_id);
        let parent_folder = find_folder_mut(root, parent_folder_id);

        let folder = Folder {
            id: object::new(ctx),
            name: string::utf8(name),
            parent_id: parent_folder_id,
            child_ids: vec_map::empty()
        };

        let folder_id = object::id(&folder);
        vec_map::insert(&mut parent_folder.child_ids, folder_id, true);
        dof::add(&mut parent_folder.id, folder_id, folder);

        event::emit(FolderCreated {
            folder_id,
            name: string::utf8(name),
            parent_id: parent_folder_id
        });
    }

    public entry fun create_file_in_root(
        _admin: &AdminCap,
        root: &mut RootFolder,
        name: vector<u8>,
        ipfs_hash: vector<u8>,
        ctx: &mut TxContext
    ) {
        let root_id = object::id(root);
        let file = File {
            id: object::new(ctx),
            name: string::utf8(name),
            parent_id: root_id,
            ipfs_hash: string::utf8(ipfs_hash)
        };

        let file_id = object::id(&file);
        vec_map::insert(&mut root.child_ids, file_id, true);
        
        event::emit(FileCreated {
            file_id,
            name: string::utf8(name),
            parent_id: root_id
        });

        dof::add(&mut root.id, file_id, file);
    }

    public entry fun create_file_in_folder(
        _admin: &AdminCap,
        root: &mut RootFolder,
        parent_id: vector<u8>,
        name: vector<u8>,
        ipfs_hash: vector<u8>,
        ctx: &mut TxContext
    ) {
        let parent_folder_id = object::id_from_bytes(parent_id);
        let parent_folder = find_folder_mut(root, parent_folder_id);

        let file = File {
            id: object::new(ctx),
            name: string::utf8(name),
            parent_id: parent_folder_id,
            ipfs_hash: string::utf8(ipfs_hash)
        };

        let file_id = object::id(&file);
        vec_map::insert(&mut parent_folder.child_ids, file_id, true);
        dof::add(&mut parent_folder.id, file_id, file);

        event::emit(FileCreated {
            file_id,
            name: string::utf8(name),
            parent_id: parent_folder_id
        });
    }

    // fun find_folder_mut(root: &mut RootFolder, folder_id: ID): &mut Folder {
    //     if (dof::exists_(&root.id, folder_id)) {
    //         return dof::borrow_mut<ID, Folder>(&mut root.id, folder_id)
    //     };

    //     let root_children = vec_map::keys(&root.child_ids);
    //     let i = 0;
    //     while (i < vector::length(&root_children)) {
    //         let child_id = *vector::borrow(&root_children, i);
    //         if (dof::exists_(&root.id, child_id)) {
    //             let child_folder = dof::borrow_mut<ID, Folder>(&mut root.id, child_id);
    //             if (child_id == folder_id) {
    //                 return child_folder
    //             };
                
    //             if (!vec_map::is_empty(&child_folder.child_ids)) {
    //                 let grandchild_result = find_folder_mut_recursive(child_folder, folder_id);
    //                 if (option::is_some(&grandchild_result)) {
    //                     let grandchild_id = option::destroy_some(grandchild_result);
    //                     return dof::borrow_mut<ID, Folder>(&mut child_folder.id, grandchild_id)
    //                 }
    //             }
    //         };
    //         i = i + 1;
    //     };

    //     abort E_FOLDER_NOT_FOUND
    // }

    // fun find_folder_mut_recursive(parent: &mut Folder, folder_id: ID): Option<ID> {
    //     let child_ids = vec_map::keys(&parent.child_ids);
    //     let i = 0;

    //     while (i < vector::length(&child_ids)) {
    //         let child_id = *vector::borrow(&child_ids, i);
    //         if (dof::exists_(&parent.id, child_id)) {
    //             let child_folder = dof::borrow_mut<ID, Folder>(&mut parent.id, child_id);
    //             if (child_id == folder_id) {
    //                 return option::some(child_id)
    //             };
                
    //             if (!vec_map::is_empty(&child_folder.child_ids)) {
    //                 let grandchild_result = find_folder_mut_recursive(child_folder, folder_id);
    //                 if (option::is_some(&grandchild_result)) {
    //                     return grandchild_result
    //                 }
    //             }
    //         };
    //         i = i + 1;
    //     };

    //     option::none()
    // }
    fun find_folder_mut(root: &mut RootFolder, folder_id: ID): &mut Folder {
        if (dof::exists_(&root.id, folder_id)) {
            return dof::borrow_mut<ID, Folder>(&mut root.id, folder_id)
        };

        let root_children = vec_map::keys(&root.child_ids);
        let i = 0;
        while (i < vector::length(&root_children)) {
            let child_id = *vector::borrow(&root_children, i);
            if (dof::exists_(&root.id, child_id)) {
                let child_folder = dof::borrow_mut<ID, Folder>(&mut root.id, child_id);
                if (child_id == folder_id) {
                    return child_folder
                };
                
                let grandchild_folder_id = find_folder_mut_recursive(child_folder, folder_id);
                if (option::is_some(&grandchild_folder_id)) {
                    return dof::borrow_mut<ID, Folder>(&mut child_folder.id, option::destroy_some(grandchild_folder_id))
                }
            };
            i = i + 1;
        };

        abort E_FOLDER_NOT_FOUND
    }

    fun find_folder_mut_recursive(parent: &mut Folder, folder_id: ID): Option<ID> {
        let child_ids = vec_map::keys(&parent.child_ids);
        let i = 0;
        while (i < vector::length(&child_ids)) {
            let child_id = *vector::borrow(&child_ids, i);
            if (dof::exists_(&parent.id, child_id)) {
                let child_folder = dof::borrow_mut<ID, Folder>(&mut parent.id, child_id);
                if (child_id == folder_id) {
                    return option::some(child_id)
                };
                
                let grandchild_folder_id = find_folder_mut_recursive(child_folder, folder_id);
                if (option::is_some(&grandchild_folder_id)) {
                    return grandchild_folder_id
                }
            };
            i = i + 1;
        };

        option::none()
    }

    public fun get_root_contents(root: &RootFolder): &VecMap<ID, bool> {
        &root.child_ids
    }

    public fun get_folder_contents(folder: &Folder): &VecMap<ID, bool> {
        &folder.child_ids
    }

    public fun get_file_details(file: &File): (String, String) {
        (file.name, file.ipfs_hash)
    }

    public fun get_folder_name(folder: &Folder): String {
        folder.name
    }

    public fun get_parent_id(folder: &Folder): ID {
        folder.parent_id
    }
}