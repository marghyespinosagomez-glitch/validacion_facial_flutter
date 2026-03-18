use dlib_face_recognition::*;
use rusqlite::{params, Connection};
use uuid::Uuid;
use image::RgbImage;

// Estructura que Flutter verá
pub struct FaceRegistration {
    pub db_path: String,
    pub user_name: String,
    pub photo_bytes: Vec<u8>,
}

fn tick<R>(name: &str, f: impl FnOnce() -> R) -> R {
    let now = std::time::Instant::now();
    let result = f();
    println!("[{}] elapsed time: {}ms", name, now.elapsed().as_millis());
    result
}

pub fn process_registration(data: FaceRegistration) -> anyhow::Result<String> {
    // 1. Cargar imagen desde memoria (data.photo_bytes)
    let first_photo = image::load_from_memory(&data.photo_bytes)
        .map_err(|e| anyhow::anyhow!("Error decodificando imagen: {}", e))?
        .to_rgb8();

    let matrix_photo_1 = ImageMatrix::from_image(&first_photo);

    // 2. Cargar modelos (usando ? en lugar de panic!)
    let cnn_detector = FaceDetectorCnn::default()
        .map_err(|_| anyhow::anyhow!("Error cargando Face Detector"))?;
    let landmarks_predictor = LandmarkPredictor::default()
        .map_err(|_| anyhow::anyhow!("Error cargando Landmark Predictor"))?;
    let face_encoder = FaceEncoderNetwork::default()
        .map_err(|_| anyhow::anyhow!("Error cargando Face Encoder"))?;

    // 3. Detectar rostros
    let face_locations = tick("FaceDetectorCnn", || {
        cnn_detector.face_locations(&matrix_photo_1)
    });

    if face_locations.is_empty() {
        return Err(anyhow::anyhow!("NO_FACE_DETECTED"));
    }

    if face_locations.len() > 1 {
        return Err(anyhow::anyhow!("MULTIPLE_FACES_DETECTED"));
    }

    // 4. Procesar el rostro único
    let location = &face_locations[0];
    let landmarks = landmarks_predictor.face_landmarks(&matrix_photo_1, location);
    let encodings = face_encoder.get_face_encodings(&matrix_photo_1, &[landmarks], 0);

    if let Some(face_measurements) = encodings.first() {
        // Convertimos el encoding de dlib a Vec<f32>
        let embedding_vec: Vec<f32> = face_measurements.as_ref().to_vec();
        
        // Llamamos a la función de guardado
        let uuid = save_face(&data, embedding_vec)?;
        
        println!("Rostro registrado exitosamente con UUID: {}", uuid);
        Ok(uuid)
    } else {
        Err(anyhow::anyhow!("COULD_NOT_EXTRACT_EMBEDDING"))
    }
}

// Función interna de guardado
fn save_face(config: &FaceRegistration, embedding: Vec<f32>) -> anyhow::Result<String> {
    let conn = Connection::open(&config.db_path)?;
    let new_uuid = Uuid::new_v4().to_string();

    // Asegurarse de que la tabla existe
    conn.execute(
        "CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY, 
            uuid TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            embedding BLOB NOT NULL
        )",
        [],
    )?;

    // Conversión segura de Vec<f32> a bytes
    let bytes: &[u8] = unsafe {
        std::slice::from_raw_parts(
            embedding.as_ptr() as *const u8,
            embedding.len() * std::mem::size_of::<f32>(),
        )
    };

    conn.execute(
        "INSERT INTO users (uuid, name, embedding) VALUES (?1, ?2, ?3)",
        params![new_uuid, config.user_name, bytes],
    )?;

    Ok(new_uuid)
}




// use dlib_face_recognition::*;
// use dlib_face_recognition::FaceDetectorCnn;
// use clap::Parser;
// use rusqlite::{params, Connection};
// use uuid::Uuid;
// use image::{DynamicImage, RgbImage};
// // mod args;

// // use args::Args;
// pub struct FaceRegistration {
//     pub db_path: String,
//     pub user_name: String,
//     pub photo_bytes: Vec<u8>
// }

// fn tick<R>(name: &str, f: impl Fn() -> R) -> R {
//     let now = std::time::Instant::now();
//     let result = f();
//     println!("[{}] elapsed time: {}ms", name, now.elapsed().as_millis());
//     result
// }

// fn process_registration(data: FaceRegistration) -> anyhow::Result<String> {
//     // let image1 = "/home/marghy/my_app/validacion_facial/assets/multi_rostros.jpeg";

//     // let first_photo = image
//     //     ::open(image1)
//     //     .expect("No se pudo encontrar la imagen en la ruta especificada")
//     //     .to_rgb8();

//     let first_photo = image::load_from_memory(photo_bytes)
//         .expect("No se pudo decodificar la imagen desde los bytes")
//         .to_rgb8();

//     let matrix_photo_1 = ImageMatrix::from_image(&first_photo);

//     let Ok(cnn_detector) = FaceDetectorCnn::default() else {
//         panic!("Error loading Face Detector (CNN).");
//     };

//     let Ok(landmarks) = LandmarkPredictor::default() else {
//         panic!("Error loading Landmark Predictor.");
//     };

//     let Ok(face_encoder) = FaceEncoderNetwork::default() else {
//         panic!("Error loading Face Encoder.");
//     };

//     let face_locations_photo_1 = tick("FaceDetectorCnn", ||
//         cnn_detector.face_locations(&matrix_photo_1)
//     );

//     println!("Face embedding: {}", face_locations_photo_1.len());

//     if face_locations_photo_1.is_empty() {
//         println!("No se detectó ningún rostro en la imagen.");
//         return "NO_FACE";
//     }

//     let mut todos_los_descriptores = Vec::new();

//     for (i, location) in face_locations_photo_1.iter().enumerate() {
//         let landmarks_face_1 = landmarks.face_landmarks(&matrix_photo_1, &location);

//         let encodings_face_1 = face_encoder.get_face_encodings(
//             &matrix_photo_1,
//             &[landmarks_face_1],
//             0
//         );

//         if let Some(face_measurements) = encodings_face_1.first() {
//             // Clonamos el resultado para guardarlo en nuestra lista
//             if face_locations_photo_1.len() ==1{
//                 let uuid = save_face(&data.db_path, &data.person_name, face_measurements)
//                 Ok(uuid)
//             }
//             todos_los_descriptores.push(face_measurements.clone());
//             println!(
//                 "Longitud del embedding del rostro #{}: {}",
//                 i + 1,
//                 face_measurements.as_ref().len()
//             );
//             println!("Rostro #{} agregado al array.", i + 1);
//         }
//     }

//     println!("Total de rostros capturados: {}", todos_los_descriptores.len());
// }

// pub fn save_face(config: FaceRegistration, embedding: Vec<f32>) -> anyhow::Result<()>{

//     let conn = Connection::open(db_path)?;
//     let new_uuid = Uuid::new_v4().to_string();

//     conn.execute(
//         "CREATE TABLE IF NOT EXISTS face_data (
//             id INTEGER PRIMARY KEY, 
//             uuid TEXT NOT NULL UNIQUE,
//             name TEXT NOT NULL,
//             embedding BLOB NOT NULL
//         )",
//         [],
//     )?;

//     let bytes: &[u8] = unsafe {
//         std::slice::from_raw_parts(
//             embedding.as_ptr() as *const u8,
//             embedding.len() * std::mem::size_of::<f32>(),
//         )
//     };

//     conn.execute(
//         "INSERT INTO users (uuid, name, embedding) VALUES (?1, ?2, ?3)",
//         params![new_uuid, config.user_name, bytes],
//     )?;

//     Ok(new_uuid)

// }
