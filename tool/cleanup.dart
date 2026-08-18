import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('==============================================');
  print('   SUPABASE REST & STORAGE PURGE / CLEANUP    ');
  print('==============================================\n');

  const supabaseUrl = 'https://vuoywocxaxmqjuoohlvn.supabase.co';
  const supabaseKey = 'sb_publishable_N0fu3cJGE_EVh9fD5m9nEw_roy5ZiFS';

  final client = HttpClient();

  final headers = {
    'apikey': supabaseKey,
    'Authorization': 'Bearer $supabaseKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  // 1. Delete all rows from players table
  try {
    print('[1/3] Deleting all rows from "players" table...');
    final uri = Uri.parse('$supabaseUrl/rest/v1/players?id=neq.00000000-0000-0000-0000-000000000000');
    final req = await client.deleteUrl(uri);
    headers.forEach((k, v) => req.headers.set(k, v));
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('  Status: ${res.statusCode}');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final List list = jsonDecode(body.isEmpty ? '[]' : body);
      print('  ✓ Deleted ${list.length} player record(s).');
    } else {
      print('  ⚠ Response: $body');
    }
  } catch (e) {
    print('  ⚠ Error: $e');
  }

  // 2. Delete all rows from rooms table
  try {
    print('\n[2/3] Deleting all rows from "rooms" table...');
    final uri = Uri.parse('$supabaseUrl/rest/v1/rooms?id=neq.00000000-0000-0000-0000-000000000000');
    final req = await client.deleteUrl(uri);
    headers.forEach((k, v) => req.headers.set(k, v));
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('  Status: ${res.statusCode}');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final List list = jsonDecode(body.isEmpty ? '[]' : body);
      print('  ✓ Deleted ${list.length} room record(s).');
    } else {
      print('  ⚠ Response: $body');
    }
  } catch (e) {
    print('  ⚠ Error: $e');
  }

  // 3. List and delete all photos in 'game-photos' bucket
  try {
    print('\n[3/3] Deleting all uploaded photos from "game-photos" bucket...');
    final listUri = Uri.parse('$supabaseUrl/storage/v1/object/list/game-photos');
    final listReq = await client.postUrl(listUri);
    headers.forEach((k, v) => listReq.headers.set(k, v));
    listReq.write(jsonEncode({'prefix': '', 'limit': 1000}));
    final listRes = await listReq.close();
    final listBody = await listRes.transform(utf8.decoder).join();

    if (listRes.statusCode >= 200 && listRes.statusCode < 300) {
      final List items = jsonDecode(listBody);
      final List<String> pathsToDelete = [];

      for (final item in items) {
        final name = item['name'] as String? ?? '';
        if (name.isEmpty) continue;

        // Check if item is a folder by querying inside it
        final subUri = Uri.parse('$supabaseUrl/storage/v1/object/list/game-photos');
        final subReq = await client.postUrl(subUri);
        headers.forEach((k, v) => subReq.headers.set(k, v));
        subReq.write(jsonEncode({'prefix': name, 'limit': 1000}));
        final subRes = await subReq.close();
        final subBody = await subRes.transform(utf8.decoder).join();

        if (subRes.statusCode >= 200 && subRes.statusCode < 300) {
          final List subItems = jsonDecode(subBody);
          for (final sub in subItems) {
            final subName = sub['name'] as String? ?? '';
            if (subName.isNotEmpty && subName != name) {
              pathsToDelete.add('$name/$subName');
            }
          }
        }
        pathsToDelete.add(name);
      }

      if (pathsToDelete.isNotEmpty) {
        print('  Found ${pathsToDelete.length} files/paths to delete: $pathsToDelete');
        final delUri = Uri.parse('$supabaseUrl/storage/v1/object/game-photos');
        final delReq = await client.deleteUrl(delUri);
        headers.forEach((k, v) => delReq.headers.set(k, v));
        delReq.write(jsonEncode({'prefixes': pathsToDelete}));
        final delRes = await delReq.close();
        final delBody = await delRes.transform(utf8.decoder).join();
        print('  Status: ${delRes.statusCode}');
        print('  ✓ Deleted files: $delBody');
      } else {
        print('  ✓ Bucket is already clean (0 files found).');
      }
    } else {
      print('  ⚠ List response: $listBody');
    }
  } catch (e) {
    print('  ⚠ Error cleaning storage: $e');
  } finally {
    client.close();
  }

  print('\n==============================================');
  print('           ALL ROOMS & PHOTOS PURGED!          ');
  print('==============================================\n');
}
